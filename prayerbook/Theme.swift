//
//  Theme.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/12/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import ChameleonFramework

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
            UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue : UIColor.black])
            UITabBar.appearance().barTintColor = UIColor(red: 255/255.0, green: 233/255.0, blue: 210/255.0, alpha: 1.0)
            UITabBar.appearance().tintColor = UIColor.red

        case .Chameleon(let color):
            mainColor = color
            textColor = ContrastColorOf(mainColor!, returnFlat: false)
            secondaryColor = textColor?.flatten()
            
            Chameleon.setGlobalThemeUsingPrimaryColor(mainColor, withSecondaryColor: secondaryColor, andContentStyle: .contrast)
            UITabBar.appearance().tintColor = secondaryColor

        }
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
