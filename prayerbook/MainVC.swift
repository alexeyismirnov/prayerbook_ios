//
//  MainVC.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 7/12/15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class MainVC: UITabBarControllerAnimated {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)

        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()
        tabBar.backgroundColor = .clear
        
        reload()
    }
    
    func reload() {
        if let controllers = viewControllers  {
            (controllers[0] as! UINavigationController).title = Translate.s("Daily")
            (controllers[1] as! UINavigationController).title = Translate.s("Library")
        }
    }
    
}
