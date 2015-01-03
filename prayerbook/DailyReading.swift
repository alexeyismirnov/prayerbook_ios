//
//  DailyReading.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct DailyReading {

    static func GospelOfLent(date: NSDate) -> String {
        let bundle = NSBundle.mainBundle().pathForResource("ReadingLent", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as [String]

        let dayNum = Cal.d(.SundayOfPublicianAndPharisee) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfJohn(date: NSDate) -> String {
        let bundle = NSBundle.mainBundle().pathForResource("ReadingJohn", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as [String]
        
        let dayNum = Cal.d(.Pascha) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfMatthew(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as [String]

        let bundleMatthew = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleMatthew!) as [String]

        var dayNum = Cal.d(.HolySpirit) >> date;
        var readings = apostle[dayNum] + " "
        
        if dayNum >= 17*7 {
            NSLog("matt exceeding 17 weeks by \(dayNum-17*7+1) days")
            dayNum = dayNum - 7*7
        }
        
        readings += gospel[dayNum]
        return readings
    }
    
    static func GospelOfLukeSpring(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as [String]
        
        let bundleLuke = NSBundle.mainBundle().pathForResource("ReadingLuke", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleLuke!) as [String]

        let PAPSunday = Cal.d(.SundayOfPublicianAndPharisee)
        let daysFromPentecost = Cal.d(.HolySpiritPrevYear) >> date
        let daysFromExaltation = (Cal.d(.SundayAfterExaltationPrevYear)+1.days) >> date
        let daysBeforePAP = date >> PAPSunday
        
        var gospelIndex:Int, apostleIndex:Int
        
        if daysFromExaltation >= 16*7-1 {
            gospelIndex = 111 - daysBeforePAP
            apostleIndex = 230 - daysBeforePAP
            
        } else if daysFromPentecost >= 33*7-1 {
            gospelIndex = daysFromExaltation
            apostleIndex = 230 - daysBeforePAP

        } else {
            gospelIndex = daysFromExaltation
            apostleIndex = daysFromPentecost
        }
        
        return apostle[apostleIndex] + " " + gospel[gospelIndex]
    }

    static func GospelOfLukeFall(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as [String]
        
        let bundleLuke = NSBundle.mainBundle().pathForResource("ReadingLuke", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleLuke!) as [String]

        var daysFromPentecost = Cal.d(.HolySpirit) >> date;
        var daysFromLukeStart = (Cal.d(.SundayAfterExaltation)+1.days) >> date;

        var readings = apostle[daysFromPentecost] + " " + gospel[daysFromLukeStart]

        return readings
    }
    
    static func getDailyReading(date: NSDate) -> [String] {
        Cal.setDate(date)
        
        switch (date) {
        case Cal.d(.StartOfYear) ..< Cal.d(.SundayOfPublicianAndPharisee):
            return [GospelOfLukeSpring(date)]
            
        case Cal.d(.SundayOfPublicianAndPharisee) ..< Cal.d(.Pascha):
            return [GospelOfLent(date)]
            
        case Cal.d(.Pascha) ... Cal.d(.Pentecost):
            return [GospelOfJohn(date)]
            
        case Cal.d(.HolySpirit) ... Cal.d(.SundayAfterExaltation):
            return [GospelOfMatthew(date)]
            
        case Cal.d(.SundayAfterExaltation)+1.days ... Cal.d(.EndOfYear):
            return [GospelOfLukeFall(date)]
            
        default: return []
        }
    }
}
