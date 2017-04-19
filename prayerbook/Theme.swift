//
//  Theme.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/12/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import Chameleon

enum AppTheme {
    case Default
    case Chameleon(color: UIColor)
}

struct Theme {
    static var textColor: UIColor!
    static var mainColor : UIColor?
    static var secondaryColor : UIColor!
    
    static func set(_ t: AppTheme) {
        switch t {
        case .Default:
            mainColor = nil
            textColor = UIColor.black
            secondaryColor = UIColor.init(hex: "#804000")
            
            UINavigationBar.appearance().barTintColor = UIColor(red: 255/255.0, green: 233/255.0, blue: 210/255.0, alpha: 1.0)
            UINavigationBar.appearance().tintColor = UIColor.blue
            UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
            UITabBar.appearance().barTintColor = UIColor(red: 255/255.0, green: 233/255.0, blue: 210/255.0, alpha: 1.0)
            UITabBar.appearance().tintColor = UIColor.red

        case .Chameleon(let color):
            mainColor = color
            textColor = ContrastColorOf(mainColor!, returnFlat: false)
            secondaryColor = textColor?.flatten()
            
            Chameleon.setGlobalThemeUsingPrimaryColor(mainColor, withSecondaryColor: secondaryColor, andContentStyle: .contrast)
        }
    }
    
}
