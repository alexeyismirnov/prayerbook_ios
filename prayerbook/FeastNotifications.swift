//
//  FeastNotifications.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/30/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import UserNotifications
import swift_toolkit

struct FeastNotifications {
    static let center = UNUserNotificationCenter.current()

    static func addNotification(_ date: Date, _ descr : String, _ body:String = "") {
        var components = DateComponents(date: date)
        components.hour = 17
        components.minute = 00
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = descr
        content.body = body
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        }
    }
    
    static func setupNotifications() {
        FeastList.sharing = false
        FeastList.setDate(Date())
        
        center.requestAuthorization(options:  [.alert, .sound]) {
            (granted, error) in
            if granted {
                center.removeAllPendingNotificationRequests()
                
                for (date, descr) in FeastList.longFasts {
                    addNotification(date-1.days, "", descr.string)
                }
                
                for (date, descr) in FeastList.shortFasts {
                    addNotification(date-1.days,  "День постный", descr.string)
                }
                
                for (date, descr) in FeastList.fastFreeWeeks {
                    addNotification(date-1.days,  "Сплошная седмица, поста нет", descr.string)
                }
                 
                for (date, descr) in FeastList.movableFeasts {
                    addNotification(date-1.days, "", descr.string)
                }
                
                for (date, descr) in FeastList.nonMovableFeasts {
                    if (date == Cal.d(.exaltationOfCross)) {
                        // print("cross")
                    } else {
                        addNotification(date-1.days, "", descr.string)
                    }
                }
                
                for (date, descr) in FeastList.greatFeasts {
                    if (date == Cal.d(.beheadingOfJohn)) {
                        // print("beheading")
                    } else {
                        addNotification(date-1.days, "", descr.string)
                    }
                }
                
                /*
                center.getPendingNotificationRequests { (notifications) in
                    print("Count: \(notifications.count)")
                    for item in notifications {
                        let trigger = item.trigger as! UNCalendarNotificationTrigger
                        
                        print(trigger.nextTriggerDate())
                        print(item.content)
                    }
                }
                */
                
            }
        }
    }
    
}

