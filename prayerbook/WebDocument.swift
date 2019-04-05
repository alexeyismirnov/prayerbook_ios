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

class WebDocument: UIViewController {
    let prefs = UserDefaults(suiteName: groupId)!
    var fontSize: Int = 0
    var webView: WKWebView!

    var con : [NSLayoutConstraint]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView()
        webView.isOpaque = false
        webView.backgroundColor = .clear
        
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        con = [
            webView.topAnchor.constraint(equalTo: view.topAnchor, constant: navigationController!.navigationBar.frame.height + UIApplication.shared.statusBarFrame.height),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -tabBarController!.tabBar.frame.size.height),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ]
        
        NSLayoutConstraint.activate(con)
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        fontSize = prefs.integer(forKey: "fontSize")
        
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        let button_zoom_in = CustomBarButton(image: UIImage(named: "zoom_in", in: toolkit, compatibleWith: nil)!
            , target: self, btnHandler: #selector(self.zoom_in))
        let button_zoom_out = CustomBarButton(image: UIImage(named: "zoom_out", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(self.zoom_out))
        
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        let content = "<html><body><p><font size=30>" + randomString(length: 2000) + "</font></p></body></html>"
        webView.loadHTMLString(content, baseURL: nil)
        
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefijk "
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    @objc func zoom_in() {
    }
    
    @objc func zoom_out() {
    }
    
}

