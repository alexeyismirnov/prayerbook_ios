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
        let readings = [
            "Acts 1:1-8         John 1:1-17",       // Pascha
            "Acts 1:12-17,21-26 John 1:18-28",
            "Acts 2:14-21       Luke 24:12-35",
            "Acts 2:22-36       John 1:35-51",
            "Acts 2:38-43       John 3:1-15",
            "Acts 3:1-8         John 2:12-22",
            "Acts 3:11-16       John 3:22-33",
            "Acts 5:12-20       John 20:19-31",     // 2nd Sunday
            "Acts 3:19-26       John 2:1-11",
            "Acts 4:1-10        John 3:16-21",
            "Acts 4:13-22       John 5:17-24",
            "Acts 4:23-31       John 5:24-30",
            "Acts 5:1-11        John 5:30-6:2",
            "Acts 5:21-33       John 6:14-27",
            "Acts 6:1-7         Mark 15:43-16:8",   // 3rd Sunday
            "Acts 6:8-7:5,47-60 John 4:46-54",
            "Acts 8:5-17        John 6:27-33",
            "Acts 8:18-25       John 6:35-39",
            "Acts 8:26-39       John 6:40-44",
            "Acts 8:40-9:19     John 6:48-54",
            "Acts 9:20-31       John 15:17-16:2",
            "Acts 9:32-42       John 5:1-15",       // 4th Sunday
            "Acts 10:1-16       John 6:56-69",
            "Acts 10:21-33      John 7:1-13",
            "Acts 14:6-18       John 7:14-30",
            "Acts 10:34-43      John 8:12-20",
            "Acts 10:44-11:10   John 8:21-30",
            "Acts 12:1-11       John 8:31-42",
            "Acts 11:19-26,29-30 John 4:5-42",      // 5th Sunday
            "Acts 12:12-17      John 8:42-51",
            "Acts 12:25-13:12   John 8:51-59",
            "Acts 13:13-24      John 6:5-14",
            "Acts 14:20-27      John 9:39-10:9",
            "Acts 15:5-34       John 10:17-28",
            "Acts 15:35-41      John 10:27-38",
            "Acts 16:16-34      John 9:1-38",       // 6th Sunday
            "Acts 17:1-15       John 11:47-57",
            "Acts 17:19-28      John 12:19-36",
            "Acts 18:22-28      John 12:36-47",
            "Acts 1:1-12        Luke 24:36-53",
            "Acts 19:1-8        John 14:1-11",
            "Acts 20:7-12       John 14:10-21",
            "Acts 20:16-18,28-36 John 17:1-13",     // 7th Sunday
            "Acts 21:8-14       John 14:27-15:7",
            "Acts 21:26-32      John 16:2-13",
            "Acts 23:1-11       John 16:15-23",
            "Acts 25:13-19      John 16:23-33",
            "Acts 27:1-44       John 17:18-26",
            "Acts 28:1-31       John 21:15-25",
            "Acts 2:1-11        John 7:37-52,8:12-12"  // Pentecost
        ]
        
        let dayNum = Cal.d(.Pascha) >> date;
        
        return readings[dayNum]
    }
    
    static func getDailyReading(date: NSDate) -> [String] {

        Cal.setDate(date)
        
        switch (date) {
        case Cal.d(.Pascha) ... Cal.d(.Pentecost):
            return [GospelOfJohn(date)]
            
        default: return []
        }
    }
}
