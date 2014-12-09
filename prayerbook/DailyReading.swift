//
//  DailyReading.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct DailyReading {

    static func GospelOfJohn(date: NSDate) -> String {
        return "Acts 1:22-2:2,25-29 John 1:1-3"
    }
    
    static func getDailyReading(date: NSDate) -> [String] {

        switch (date) {
        case Cal.d(.Pascha) ... Cal.d(.Pentecost):
            return [GospelOfJohn(date)]
            
        default: return []
        }
    }
}
