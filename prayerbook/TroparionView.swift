//
//  TroparionView.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/1/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class TroparionView: UIViewController {
    var fontSize: Int = 0
    let prefs = UserDefaults(suiteName: groupId)!
    var textView : UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(closeView))
        navigationItem.leftBarButtonItem = backButton
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(Scripture.zoom_in))
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(Scripture.zoom_out))
        
        button_zoom_in.imageInsets = UIEdgeInsetsMake(0,-20,0,0)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        fontSize = prefs.integer(forKey: "fontSize")
        
        textView =  UITextView(frame: .zero)
        textView.backgroundColor = .clear
        textView.isScrollEnabled = true
        textView.isPagingEnabled = false
        textView.bounces = false
        textView.isEditable = false
        
        view.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 10),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
        ])

        reload()
    }
    
    func zoom_in() {
        fontSize += 2
        prefs.set(fontSize, forKey: "fontSize")
        prefs.synchronize()
        
        reload()
    }
    
    func zoom_out() {
        fontSize -= 2
        prefs.set(fontSize, forKey: "fontSize")
        prefs.synchronize()
        
        reload()
    }
    
    func closeView() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    func reload() {
    }
    
    
}

