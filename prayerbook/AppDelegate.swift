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
    var openDate: NSDate?
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        
        if url.scheme == "ponomar-ru" {
            openDate = NSDate(timeIntervalSince1970: Double(url.query!)!)            
        }
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if let root = window?.rootViewController as? MainVC,
            controllers = root.viewControllers,
            nav = controllers[0] as? UINavigationController,
            vc = nav.topViewController as? DailyTab,
            date = openDate {
                root.selectedIndex = 0
                vc.currentDate = date
                vc.reload()

                openDate = nil
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        let prefs = NSUserDefaults(suiteName: groupId)!
        
        // the first time app is launched
        if prefs.objectForKey("fontSize") == nil {

            prefs.setObject("ru", forKey: "language")

            if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
                prefs.setInteger(18, forKey: "fontSize")
            } else {
                prefs.setInteger(20, forKey: "fontSize")
            }
            
            prefs.synchronize()
        }
        
        if prefs.objectForKey("fastingLevel") == nil {
            prefs.setInteger(1, forKey: "fastingLevel")
            prefs.synchronize()
        }
        
        setupFiles()

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]
        
        let language = prefs.objectForKey("language") as! String
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
    
    func copyFile(filename: String, _ ext: String)  {
        let fileManager = NSFileManager.defaultManager()
        let groupURL = fileManager.containerURLForSecurityApplicationGroupIdentifier(groupId)!
        let srcPath = NSBundle.mainBundle().URLForResource(filename, withExtension: ext)!
        let dstPath = groupURL.URLByAppendingPathComponent(filename+"."+ext)
        
        do {
            try fileManager.copyItemAtURL(srcPath, toURL: dstPath)
            
        } catch let error as NSError  {            
            // maybe file already exists
            // print(error.description)
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }
    
}
