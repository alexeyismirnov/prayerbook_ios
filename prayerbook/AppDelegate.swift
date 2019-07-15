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

        if url.scheme == "ponomar-ru" {
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
        let prefs = UserDefaults(suiteName: groupId)!

        if prefs.object(forKey: "theme") == nil {
            Theme.set(.Default)

        } else {
            let color = prefs.color(forKey: "theme")
            Theme.set(.Chameleon(color: color!))
        }
        
        // the first time app is launched
        if prefs.object(forKey: "fontSize") == nil {
            prefs.set("ru", forKey: "language")

            if (UIDevice.current.userInterfaceIdiom == .phone) {
                prefs.set(20, forKey: "fontSize")
            } else {
                prefs.set(22, forKey: "fontSize")
            }
        }
        
        if prefs.object(forKey: "fastingLevel") == nil {
            FastingLevel.laymen.save()
        }
        
        if prefs.object(forKey: "bookmarks") == nil {
            prefs.set([String](), forKey: "bookmarks")
        }
        
        prefs.synchronize()
        
        setupFiles()

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]
        
        let language = prefs.object(forKey: "language") as! String
        Translate.language = language
        
        FeastNotifications.setupNotifications()
        
        return true
    }
    
    func setupFiles() {
        for lang in ["ru"] {
            for month in 1...12 {
                let filename = String(format: "saints_%02d_%@", month, lang)
                copyFile(filename, "sqlite")
            }
        }
        
        copyFile("trans_ui_ru", "plist")
        copyFile("trans_cal_ru", "plist")
        copyFile("trans_library_ru", "plist")
        copyFile("fasting", "plist")
    }
    
    func copyFile(_ filename: String, _ ext: String)  {
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupId)!
        let srcPath = Bundle.main.url(forResource: filename, withExtension: ext)!
        let dstPath = groupURL.appendingPathComponent(filename+"."+ext)
        
        do {            
            let data = try Data(contentsOf: srcPath)
            try data.write(to: dstPath, options: .atomic)
            
        } catch let error as NSError  {            
            print(error.description)
        }
    }
    
}
