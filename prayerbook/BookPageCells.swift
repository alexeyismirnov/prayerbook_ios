//
//  BookPageCells.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import Foundation
import WebKit
import UIKit

import swift_toolkit

class BookPageCellText: UICollectionViewCell, UITextViewDelegate {
    var cellFrame: CGRect! {
        didSet {
            textView.frame = cellFrame
        }
    }
    
    var textView: UITextView!
    var delegate: BookPageDelegate!
    
    var attributedText : NSAttributedString! {
        didSet {
            updateText()
        }
    }
    
    func updateText() {
        let fontSize = AppGroup.prefs.integer(forKey: "fontSize")

        if Translate.language == "cn" {
            textView.attributedText = attributedText
            
            textView.font = UIFont(name: "STHeitiSC-Light" ,
                                   size: CGFloat(fontSize))!
            
        } else {
            textView.font = UIFont(name: "TimesNewRomanPSMT",
                                   size: CGFloat(fontSize))!
            
            textView.attributedText = attributedText
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                        
        textView = UITextView(frame: frame)
        textView.delegate = self
        
        contentView.addSubview(textView)
        
        textView.textColor = Theme.textColor
        
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = true
        textView.scrollRangeToVisible(NSRange(location:0, length:0))
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var newFrame: CGRect
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            newFrame = delegate.hideBars()
            
        } else {
            newFrame = delegate.showBars()
        }
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.textView.frame = newFrame
                       })
    }
}

class BookPageCellHTML: UICollectionViewCell, WKNavigationDelegate, UIScrollViewDelegate {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

    var webView: WKWebView!
    
    var cellFrame: CGRect! {
        didSet {
            webView.frame = cellFrame
        }
    }
    
    let header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
    let bookIcon  = """
            .icon {
            width: 24px;
            height: 24px;
        background-image:url('data:image/svg+xml;utf8,<svg enable-background="new 0 0 48 48" height="48px" id="Layer_1" version="1.1" viewBox="0 0 48 48" width="48px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"><path style="fill: red" clip-rule="evenodd" d="M37,47H11c-2.209,0-4-1.791-4-4V5c0-2.209,1.791-4,4-4h18.973  c0.002,0,0.005,0,0.007,0h0.02H30c0.32,0,0.593,0.161,0.776,0.395l9.829,9.829C40.84,11.407,41,11.68,41,12l0,0v0.021  c0,0.002,0,0.003,0,0.005V43C41,45.209,39.209,47,37,47z M31,4.381V11h6.619L31,4.381z M39,13h-9c-0.553,0-1-0.448-1-1V3H11  C9.896,3,9,3.896,9,5v38c0,1.104,0.896,2,2,2h26c1.104,0,2-0.896,2-2V13z M33,39H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18  c0.553,0,1,0.448,1,1C34,38.553,33.553,39,33,39z M33,31H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1  C34,30.553,33.553,31,33,31z M33,23H15c-0.553,0-1-0.447-1-1c0-0.552,0.447-1,1-1h18c0.553,0,1,0.448,1,1C34,22.553,33.553,23,33,23  z" fill-rule="evenodd"/></svg>');
            background-size: 24px;
        
            }
        """
        
    var text : String! {
        didSet {
            updateText()
        }
    }
    
    var delegate: BookPageDelegate!
    var model: BookModel!
    
    func updateText() {
        let color = Theme.textColor.toHexString()
        let fontSize = AppGroup.prefs.integer(forKey: "fontSize")

        let styleCSS = """
        <style type='text/css'>
        body {font-size: \(fontSize)px; color: \(color); }
        .rubric { color: red; font-size: 80%; }
        .author { color: red; font-size: 110%; font-weight:bold; }
        \(bookIcon)
        </style>
        """
        
        let htmlHead = header + "<html><head>" + styleCSS
        webView.loadHTMLString(htmlHead + "</head><body>" + text + "</body></html>", baseURL: toolkit!.bundleURL)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        webView = WKWebView(frame: frame)
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(webView)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url
            else { decisionHandler(.allow); return }
        
        if url.scheme == "comment"  {
            let fontSize = AppGroup.prefs.integer(forKey: "fontSize")
            let id = Int(url.host!)!
            let text = model.getComment(commentId: id)
            
            let labelVC = LabelViewController()
            labelVC.text = text
            labelVC.fontSize = fontSize
            
            delegate.showComment(labelVC)
            
            decisionHandler(.cancel)

        } else {
            decisionHandler(.allow)
        }
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var newFrame: CGRect
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            newFrame = delegate.hideBars()
            
        } else {
            newFrame = delegate.showBars()
        }
        
        UIView.animate(withDuration: 0.5,
                       animations: {
                        self.webView.frame = newFrame
                       })
    }
}


extension BookPageCellText: ReusableView {}
extension BookPageCellHTML: ReusableView {}
