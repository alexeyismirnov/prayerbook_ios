//
//  ChurchTab.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class ChurchTab: UIViewController {
    let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")

    override func viewDidLoad() {
        navigationController?.makeTransparent()
        title = Translate.s("Church")

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: .themeChangedNotification, object: nil)
        
        reloadTheme()
    }

    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor

        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
    }
    
}

