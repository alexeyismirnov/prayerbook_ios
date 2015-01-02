//
//  DailyReading.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct DailyReading {

    static var sundayAfterExaltation:NSDate!
    
    static func GospelOfJohn(date: NSDate) -> String {
        let readings = [""]
        
        let dayNum = Cal.d(.Pascha) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfMatthew(date: NSDate) -> String {
        let readings = [""]

        var dayNum = Cal.d(.Pentecost) >> date;
        if dayNum > 17*7 {
            NSLog("matt exceeding 17 weeks by \(dayNum-17*7) days")
            dayNum = dayNum - 17*7
        }
        
        return readings[dayNum]
    }
    
    static func GospelOfLuke(date: NSDate) -> String {
        let readings = [""]

        var dayNum = Cal.d(.Pentecost) >> date;
        return readings[dayNum]
    }
    
    static func getDailyReading(date: NSDate) -> [String] {

        Cal.setDate(date)
        
        let exaltation = Cal.d(.ExaltationOfCross)
        Cal.setDate(exaltation)
        let dayOfWeek = Cal.currentWeekday.rawValue
        sundayAfterExaltation = Cal.d(.ExaltationOfCross) + (8-dayOfWeek).days
        
        switch (date) {
        case Cal.d(.Pascha) ... Cal.d(.Pentecost):
            return [GospelOfJohn(date)]
            
        case Cal.d(.Pentecost)+1.days ... sundayAfterExaltation:
            return [GospelOfMatthew(date)]
            
        default: return []
        }
    }
}
