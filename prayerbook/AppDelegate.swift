//
//  AppDelegate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import UserNotifications

import swift_toolkit

class AppDelegate : UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        var openDate: Date

        if url.scheme == "ponomar-ru" {
            openDate = Date(timeIntervalSince1970: Double(url.query!)!)
            
            if let root = window?.rootViewController as? MainVC,
                let controllers = root.viewControllers,
                let nav = controllers[0] as? UINavigationController,
                let vc = nav.topViewController as? DailyTab2{
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
                prefs.set(18, forKey: "fontSize")
            } else {
                prefs.set(20, forKey: "fontSize")
            }
            
            prefs.synchronize()
        }
        
        if prefs.object(forKey: "fastingLevel") == nil {
            FastingLevel.monastic.save()
        }
        
        setupFiles()
        setupNotifications()

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
    
    func setupNotifications() {
        let center = UNUserNotificationCenter.current()

        let options: UNAuthorizationOptions = [.alert, .sound];

        center.requestAuthorization(options: options) {
            (granted, error) in
            if granted {
                
                center.removeAllPendingNotificationRequests()
                
                var components = DateComponents()
                components.hour = 8
                components.minute = 30
                components.weekday = DayOfWeek.monday.rawValue
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                
                let content = UNMutableNotificationContent()
                content.title = "28.11 - Начало Рождественского поста"
                content.body = ""
                content.sound = UNNotificationSound.default()
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                center.add(request) {(error) in
                    if let error = error {
                        print("Uh oh! We had an error: \(error)")
                    }
                }
                
                center.getPendingNotificationRequests { (notifications) in
                    print("Count: \(notifications.count)")
                    for item in notifications {
                        let trigger = item.trigger as! UNCalendarNotificationTrigger
                        
                        print(trigger.nextTriggerDate())
                        print(item.content)
                    }
                }
                
            }
        }

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
