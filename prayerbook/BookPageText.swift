//
//  BookPageText.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/16/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class BookPageText: BookPage {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        
        reloadTheme()
        createNavigationButtons()
        updateNavigationButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if contentView1 != nil {
            (contentView1 as! UITextView).setContentOffset(CGPoint.zero, animated: false)
        }
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
        
        if (contentView1 != nil) {
            contentView1.removeFromSuperview()
            NSLayoutConstraint.deactivate(con)
        }
        
        contentView1 = createContentView(pos)
        
        con = generateConstraints(forView: contentView1, leading: 10, trailing: -10)
        NSLayoutConstraint.activate(con)
    }
    
    override func createContentView(_ pos: BookPosition) -> UIView {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.font = UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!
        textView.backgroundColor = .clear
        textView.textColor = Theme.textColor
        textView.isScrollEnabled = true
        textView.isEditable = false
        textView.showsVerticalScrollIndicator = true
        
        textView.attributedText = model.getContent(at: pos) as! NSAttributedString
        
        view.addSubview(textView)
        textView.scrollRangeToVisible(NSRange(location:0, length:0))


        return textView
    }
    

}
