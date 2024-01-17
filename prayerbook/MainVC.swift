//
//  MainVC.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 7/12/15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class CustomToolbar: UIToolbar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var newSize: CGSize = super.sizeThatFits(size)
        newSize.height = 70  // there to set your toolbar height
        
        return newSize
    }
}

class MainVC: UITabBarControllerAnimated {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name:  .themeChangedNotification, object: nil)

        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .clear
        
        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let controllers = viewControllers  {
            (controllers[0] as! UINavigationController).title = Translate.s("Daily")
            (controllers[1] as! UINavigationController).title = Translate.s("Library")
            (controllers[2] as! UINavigationController).title = Translate.s("Church")
        }
    }
    
}
