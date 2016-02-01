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
        
        let prefs = NSUserDefaults(suiteName: "group.rlc.ponomar")!
        let fontSize = prefs.integerForKey("fontSize")
        let lang = NSLocale.preferredLanguages()[0] 
        
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
        
        setupFiles()

        Translate.files = ["trans_ui", "trans_cal", "trans_library"]
        
        let language = prefs.objectForKey("language") as! String
        Translate.language = language
        
        Appirater.setAppId("1010208102")
        Appirater.setDaysUntilPrompt(5)
        Appirater.setUsesUntilPrompt(5)
        Appirater.setSignificantEventsUntilPrompt(-1)
        Appirater.setTimeBeforeReminding(2)
        Appirater.setDebug(false)
        Appirater.appLaunched(true)
        
        return true
    }
    
    func setupFiles() {

        for lang in ["en", "cn"] {
            for month in 1...12 {
                let filename = String(format: "saints_%02d_%@", month, lang)
                copyFile(filename, "sqlite")
            }
        }
        
        copyFile("trans_ui_cn", "plist")
        copyFile("trans_cal_cn", "plist")
        copyFile("trans_library_cn", "plist")
    }
    
    func copyFile(filename: String, _ ext: String)  {
        let fileManager = NSFileManager.defaultManager()
        let groupURL = fileManager.containerURLForSecurityApplicationGroupIdentifier("group.rlc.ponomar")!
        let srcPath = NSBundle.mainBundle().URLForResource(filename, withExtension: ext)!
        let dstPath = groupURL.URLByAppendingPathComponent(filename+"."+ext)
        
        do {
            try fileManager.copyItemAtURL(srcPath, toURL: dstPath)
            
        } catch {
            // maybe file already exists
        }
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        Appirater.appEnteredForeground(true)
    }
    
}
