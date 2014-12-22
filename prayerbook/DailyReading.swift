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
            "Acts 2:1-11        John 7:37-52,8:12"  // Pentecost
        ]
        
        let dayNum = Cal.d(.Pascha) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfMatthew(date: NSDate) -> String {
        let readings = [
            "Ephes 5:9-19       Matthew 18:10-20 ",
            "Rom 1:1-7,13-17    Matthew 4:25,5:1-13",
            "Rom 1:18-27        Matthew 5:20-26",
            "Rom 1:28-2:9       Matthew 5:27-32",
            "Rom 2:14-29        Matthew 5:33-41",
            "Rom 1:7-12         Matthew 5:42-48",
            "Heb 11:33-12:2     Matthew 10:32-33,37-38,19:27-30",   // 1st Sunday
            "Rom 2:28-3,18      Matthew 6:31-34,7:9-11",
            "Rom 4:4-12         Matthew 7:15-21",
            "Rom 4:13-25        Matthew 7:21-23",
            "Rom 5:10-16        Matthew 8:23-27",
            "Rom 5:17-6:2       Matthew 9:14-17",
            "Rom 3:19-26        Matthew 7:1-8",
            "Rom 2:10-16        Matthew 4:18-23",                   // 2nd Sunday
            "Rom 7:1-13         Matthew 9:36-10:8",
            "Rom 7:14-8:2       Matthew 10:9-15",
            "Rom 8:2-13         Matthew 10:16-22",
            "Rom 8:22-27        Matthew 10:23-31",
            "Rom 9:6-19         Matthew 10:32-36,11:1",
            "Rom 3:28-4:3       Matthew 7:24-8:4",
            "Rom 5:1-10         Matthew 6:22-33",                   // 3rd Sunday
            "Rom 9:18-33        Matthew 11:2-15",
            "Rom 10:11-11:2     Matthew 11:16-20",
            "Rom 11:2-12        Matthew 11:20-26",
            "Rom 11:13-24       Matthew 11:27-30",
            "Rom 11:25-36       Matthew 12:1-8",
            "Rom 6:11-17        Matthew 8:14-23",
            "Rom 6:18-23        Matthew 8:5-13",                    // 4th Sunday
            "Rom 12:4-5:15-21   Matthew 12:9-13",
            "Rom 14:9-18        Matthew 12:14-16,22-30",
            "Rom 15:7-16        Matthew 12:38-45",
            "Rom 15:17-29       Matthew 12:46-13:3",
            "Rom 16:1-16        Matthew 13:4-9",
            "Rom 8:14-21        Matthew 9:9-13",
            "Rom 10:1-10        Matthew 8:28-9:1",                  // 5th Sunday
            "Rom 16:17-24       Matthew 13:10-23",
            "1Cor 1:1-9         Matthew 13:24-30",
            "1Cor 2:9-3:8       Matthew 13:31-36",
            "1Cor 3:18-23       Matthew 13:36-43",
            "1Cor 4:5-8         Matthew 13:44-54",
            "Rom 9:1-5          Matthew 9:18-26",
            "Rom 12:6-14        Matthew 9:1-8",                     // 6th Sunday
            "1Cor 5:9-6:11      Matthew 13:54-58",
            "1Cor 6:20-7:12     Matthew 14:1-13",
            "1Cor 7:12-24       Matthew 14:35-15:11",
            "1Cor 7:24-35       Matthew 15:12-21",
            "1Cor 7:35-8:7      Matthew 15:29-31",
            "Rom 12:1-3         Matthew 10:37-11:1",
            "Rom 15:1-7         Matthew 9:27-35",                   // 7th Sunday
            "1Cor 9:13-18       Matthew 16:1-6",
            "1Cor 10:5-12       Matthew 16:6-12",
            "1Cor 10:12-22      Matthew 16:20-24",
            "1Cor 10:28-11:7    Matthew 16:24-28",
            "1Cor 11:8-22       Matthew 17:10-18",
            "Rom 13:1-10        Matthew 12:30-37",
            "1Cor 1:10-18       Matthew 14:14-22",                  // 8th Sunday
            "1Cor 11:31-12:6    Matthew 18:1-11",
            "1Cor 12:12-26      Matthew 18:18-22,19:1-2,13-15",
            "1Cor 13:4-14:5     Matthew 20:1-16",
            "1Cor 14:6-19       Matthew 20:17-28",
            "1Cor 14:26-40      Matthew 21:12-14,17-20",
            "Rom 14:6-9         Matthew 15:32-39",
            "1Cor 3:9-17        Matthew 14:22-34",                  // 9th Sunday
            "1Cor 15:12-19      Matthew 21:18-22",
            "1Cor 15:29-38      Matthew 21:23-27",
            "1Cor 16:4-12       Matthew 21:28-32",
            "2Cor 1:1-7         Matthew 21:43-46",
            "2Cor 1:12-20       Matthew 22:23-33",
            "Rom 15:30-33       Matthew 17:24-18:4",
            "1Cor 4:9-16        Matthew 17:14-23",                  // 10th Sunday
            "2Cor 2:4-15        Matthew 23:13-22",
            "2Cor 2:14-3:3      Matthew 23:23-28",
            "2Cor 3:4-11        Matthew 23:29-39",
            "2Cor 4:1-6         Matthew 24:13-28",
            "2Cor 4:13-18       Matthew 24:27-33,42-51",
            "1Cor 1:3-9         Matthew 19:3-12",
            "1Cor 9:2-12        Matthew 18:23-35",                  // 11th Sunday
            "2Cor 5:10-15       Mark 1:9-15",
            "2Cor 5:15-21       Mark 1:16-22",
            "2Cor 6:11-16       Mark 1:23-28",
            "2Cor 7:1-10        Mark 1:29-35",
            "2Cor 7:10-16       Mark 2:18-22",
            "1Cor 1:26-29       Matthew 20:29-34",
            "1Cor 15:1-11       Matthew 19:16-26",                  // 12th Sunday
            "2Cor 8:7-15        Mark 3:6-12",
            "2Cor 8:16-9:5      Mark 3:13-19",
            "2Cor 9:12-10:7     Mark 3:20-27",
            "2Cor 10:7-18       Mark 3:28-35",
            "2Cor 11:5-21       Mark 4:1-9",
            "1Cor 2:6-9         Matthew 22:15-22",
            "1Cor 16:13-24      Matthew 21:33-42",                  // 13th Sunday
            "2Cor 12:10-19      Mark 4:10-23",
            "2Cor 12:20-13:2    Mark 4:24-34",
            "2Cor 13:3-13       Mark 4:35-41",
            "Gal 1:1-10,20-2:5  Mark 5:1-20",
            "Gal 2:6-10         Mark 5:22-24,35-6:1",
            "1Cor 4:1-5         Matthew 23:1-12",
            "2Cor 1:21-2:4      Matthew 22:1-14",                   // 14th Sunday
            "Gal 2:11-16        Mark 5:24-34",
            "Gal 2:21-3:7       Mark 6:1-7",
            "Gal 3:15-22        Mark 6:7-13",
            "Gal 3:23-4:5       Mark 6:30-45",
            "Gal 4:8-21         Mark 6:45-53",
            "1Cor 4:17-5:5      Matthew 24:1-13",
            "2Cor 4:6-15        Matthew 22:35-46",                  // 15th Sunday
            "Gal 4:28-5:10      Mark 6:54-7:8",
            "Gal 5:11-21        Mark 7:5-16",
            "Gal 6:2-10         Mark 7:14-24",
            "Ephes 1:1-9        Mark 7:24-30",
            "Ephes 1:7-17       Mark 8:1-10",
            "1Cor 10:23-28      Matthew 24:34-44",
            "2Cor 6:1-10        Matthew 25:14-30",                  // 16th Sunday
            "Ephes 1:22-2:3     Mark 10:46-52",
            "Ephes 2:19-3:7     Mark 11:11-23",
            "Ephes 3:8-21       Mark 11:23-26",
            "Ephes 4:14-19      Mark 11:27-33",
            "Ephes 4:17-25      Mark 12:1-12",
            "1Cor 14:20-25      Matthew 25:1-13",
            "2Cor 6:16-7:1      Matthew 15:21-28"                   // 17th Sunday
        ]

        let dayNum = Cal.d(.Pentecost) >> date;
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
