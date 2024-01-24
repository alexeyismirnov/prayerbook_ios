//
//  AppDelegate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class AppDelegate : UIResponder, UIApplicationDelegate {
    var window: UIWindow?
   
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        var openDate: Date
        
        if url.scheme == "ponomar" {
            openDate = Date(timeIntervalSince1970: Double(url.query!)!)
            
            if let root = window?.rootViewController as? MainVC,
                let controllers = root.viewControllers,
                let nav = controllers[0] as? UINavigationController,
                let vc = nav.topViewController as? DailyTab{
                root.selectedIndex = 0
                vc.currentDate = openDate
                
                if vc.isViewLoaded {
                    vc.reload()
                }
            }
            
            return true
            
        }  else {
            return false
        }
        
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        AppGroup.id = "group.rlc.ponomar2"
        let prefs = AppGroup.prefs!
        
        // the first time app is launched

        if prefs.object(forKey: "style") == nil {
            prefs.set(0, forKey: "style")
            Theme.set(.Default)
            
        } else {
            let style = AppStyle(rawValue: prefs.integer(forKey: "style"))!
            Theme.set(style)
        }

        if prefs.object(forKey: "fontSize") == nil {
            let lang = Locale.preferredLanguages[0]

            if (lang.hasPrefix("zh-Hans")) {
                prefs.set("cn", forKey: "language")
                
            } else if (lang.hasPrefix("zh-Hant")) {
                prefs.set("hk", forKey: "language")

            } else {
                prefs.set("en", forKey: "language")
            }
            
            if (UIDevice.current.userInterfaceIdiom == .phone) {
                prefs.set(20, forKey: "fontSize")
            } else {
                prefs.set(22, forKey: "fontSize")
            }
        }
        
        if prefs.object(forKey: "fastingLevel") == nil {
            prefs.set(0, forKey: "fastingLevel")
        }
        
        if prefs.object(forKey: "bookmarks") == nil {
            prefs.set([String](), forKey: "bookmarks")
        }
        
        prefs.synchronize()
        
        FastingModel.fastingLevel = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))

        setupFiles()
        
        Translate.files = ["trans_ui_en", "trans_cal_en",
                           "trans_ui_cn", "trans_cal_cn", "trans_library_cn",
                           "trans_ui_hk", "trans_cal_hk", "trans_library_hk"]
        
        Translate.language = prefs.object(forKey: "language") as! String
        
        FeastNotifications.setupNotifications()

        return true
    }
    
    func setupFiles() {
        for lang in ["en", "cn", "hk"] {
            for month in 1...12 {
                let filename = String(format: "saints_%02d_%@", month, lang)
                AppGroup.copyFile(filename, "sqlite")
            }
        }
        
        AppGroup.copyFile("trans_ui_en", "plist")
        AppGroup.copyFile("trans_cal_en", "plist")
        AppGroup.copyFile("trans_ui_cn", "plist")
        AppGroup.copyFile("trans_cal_cn", "plist")
        AppGroup.copyFile("trans_library_cn", "plist")
        AppGroup.copyFile("trans_ui_hk", "plist")
        AppGroup.copyFile("trans_cal_hk", "plist")
        AppGroup.copyFile("trans_library_hk", "plist")
    }
    
}
