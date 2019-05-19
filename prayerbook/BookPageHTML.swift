//
//  WebDocument.swift
//  ponomar
//
//  Created by Alexey Smirnov on 4/5/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import WebKit

class LabelViewController : UIViewController, PopupContentViewController {
    var text : String!
    var fontSize: Int!

    var con : [NSLayoutConstraint]!

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(hex: "#FFEBCD")
        
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        
        label.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!
        label.backgroundColor = .clear
        label.textColor = .black
        label.isScrollEnabled = true
        label.isEditable = false
        label.showsVerticalScrollIndicator = true

        view.addSubview(label)
        
        con = [
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(con)
        
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            return CGSize(width: 250, height: 350)
            
        } else {
            return CGSize(width: 500, height: 550)
        }
        
    }
}

class BookPageHTML: BookPage, WKNavigationDelegate {
    let header = "<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0'></header>"
    let bookIcon = """
            .icon {
            width: 20px;
            height: 20px;
            background-image:url('data:image/svg+xml;utf8,<svg enable-background="new 0 0 32 32" height="32px" id="svg2" version="1.1" viewBox="0 0 32 32" width="32px" xml:space="preserve" xmlns="http://www.w3.org/2000/svg" xmlns:cc="http://creativecommons.org/ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:svg="http://www.w3.org/2000/svg"><g id="background"><rect fill="none" height="32" width="32" x="1" y="1"/></g><g id="book_x5F_text" fill="#FF0000"><g><path d="M27.002,1v1.999h-2V5h2v28h-24c0,0-2,0-2-2V4.018c0-0.006-0.001-0.012-0.001-0.018C0.966,2.645,1.808,1.686,2.556,1.354    C3.294,0.992,3.918,1.004,4.002,1H27.002 M3.998,5C4,5,4.002,5,4.002,5h19V2.999h-19C4,3.005,3.97,2.997,3.853,3.018    c-0.115,0.019-0.274,0.06-0.404,0.125C3.196,3.314,3.035,3.353,3.002,4c0.015,0.5,0.134,0.609,0.272,0.743    c0.144,0.126,0.401,0.212,0.579,0.239C3.948,4.999,3.986,5,3.998,5 M5.002,31h20V7h-20V31"/></g><polygon points="7,23 7,21 19,21 19,23 7,23  "/><polygon points="7,15 7,13 23,13 23,15 7,15  "/><polygon points="7,19 7,17 23,17 23,19 7,19  "/></g></svg>');
            background-size: 20px;
        
            }
        """
    
    var styleCSS : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        
        reloadTheme()
        createNavigationButtons()
        showBookmarkButton()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc override func reloadTheme() {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        fontSize = prefs.integer(forKey: "fontSize")

        let color = Theme.textColor.toHexString()

        styleCSS = """
        <style type='text/css'>
        body {font-size: \(fontSize)px; color: \(color); }
        \(bookIcon)
        </style>
        """
        
        if (contentView1 != nil) {
            contentView1.removeFromSuperview()
            NSLayoutConstraint.deactivate(con)
        }
        
        contentView1 = createContentView(pos)

        con = generateConstraints(forView: contentView1, leading: 10, trailing: -10)
        NSLayoutConstraint.activate(con)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url
            else { decisionHandler(.allow); return }
        
        if url.scheme == "comment"  {
            let id = Int(url.host!)!
            let text = model.getComment(commentId: id)
            
            let labelVC = LabelViewController()
            labelVC.text = text
            labelVC.fontSize = fontSize
            
            showPopup(labelVC)
            
            decisionHandler(.cancel)

        } else {
            decisionHandler(.allow)
        }
    }
    
    override func createContentView(_ pos: BookPosition) -> UIView {
        let webView = WKWebView()
        
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(webView)
        
        let content = model.getContent(at: pos) as! String
        webView.loadHTMLString(header + "<html><head>" + styleCSS + "</head><body>" + content + "</body></html>", baseURL: Bundle.main.bundleURL)
        
        return webView
    }
    
}

