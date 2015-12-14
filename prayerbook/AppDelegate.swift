//
//  AppDelegate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class AppDelegate : UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        let fontSize = prefs.integerForKey("fontSize")
        let lang = NSLocale.preferredLanguages()[0] 

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]
        
        // the first time app is launched
        if fontSize == 0 {

            if (lang == "zh-Hans" || lang == "zh-Hant") {
                prefs.setObject("cn", forKey: "language")
            } else {
                prefs.setObject("en", forKey: "language")
            }
            
            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                prefs.setInteger(18, forKey: "fontSize")
            } else {
                prefs.setInteger(20, forKey: "fontSize")
            }
            
            prefs.synchronize()
        }
        
        let language = prefs.objectForKey("language") as! String
        Translate.language = language
        
        return true
    }
    
}
