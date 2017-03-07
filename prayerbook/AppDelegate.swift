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
    var openDate: Date?
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        if url.scheme == "ponomar-ru" {
            openDate = Date(timeIntervalSince1970: Double(url.query!)!)            
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if let root = window?.rootViewController as? MainVC,
            let controllers = root.viewControllers,
            let nav = controllers[0] as? UINavigationController,
            let vc = nav.topViewController as? DailyTab,
            let date = openDate {
                root.selectedIndex = 0
                vc.currentDate = date
                vc.reload()

                openDate = nil
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 255/255.0, green: 233/255.0, blue: 210/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.blue
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.black]
        
        let prefs = UserDefaults(suiteName: groupId)!
        
        // the first time app is launched
        if prefs.object(forKey: "fontSize") == nil {

            prefs.set("ru", forKey: "language")

            if (UIDevice.current.userInterfaceIdiom == .phone) {
                prefs.set(18, forKey: "fontSize")
            } else {
                prefs.set(20, forKey: "fontSize")
            }
            
            prefs.synchronize()
        }
        
        if prefs.object(forKey: "fastingLevel") == nil {
            prefs.set(1, forKey: "fastingLevel")
            prefs.synchronize()
        }
        
        setupFiles()

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]
        
        let language = prefs.object(forKey: "language") as! String
        Translate.language = language
        
        Appirater.setAppId("1095609748")
        Appirater.setDaysUntilPrompt(5)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
        
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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }
    
}
