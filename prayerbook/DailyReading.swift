//
//  DailyReading.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct DailyReading {
    
    struct LukeSpringParams {
        var PAPSunday : NSDate!
        var pentecostPrevYear : NSDate!
        var sundayAfterExaltationPrevYear : NSDate!
        var totalOffset : Int!
    }
    
    static var LS = LukeSpringParams()
    
    static let specialReadings : [NameOfDay: String] = [
        .NativityOfTheotokos:       "Luke 1:39-49,56 Phil 2:5-11 Luke 10:38-42,11:27-28",
        .ExaltationOfCross:         "John 12:28-36 1Cor 1:18-24 John 19:6-11,13-20,25-28,30-35",
        .VeilOfTheotokos:           "Luke 1:39-49,56 Heb 9:1-7 Luke 10:38-42,11:27-28",
        .EntryIntoTemple:           "Luke 1:39-49,56 Heb 9:1-7 Luke 10:38-42,11:27-28",
        .NativityOfGod:             "Matthew 1:18-25 Gal 4:4-7 Matthew 2:1-12",
        .Circumcision:              "John 10:1-9 Col 2:8-12 Luke 2:20-21,40-52",
        .Theophany:                 "Mark 1:9-11 Tit 2:11-14,3:4-7 Matthew 3:13-17",
        .MeetingOfLord:             "Luke 2:25-32 Heb 7:7-17 Luke 2:22-40",
        .Annunciation:              "Luke 1:39-49,56 Heb 2:11-18 Luke 1:24-38",
        .NativityOfJohn:            "Luke 1:24-25,57-68,76,80 Rom 13:12-14:4 Luke 1:5-25,57-68,76,80",
        .PeterAndPaul:              "1Cor 4:9-16 Mark 3:13-19",
        .Transfiguration:           "Luke 9:28-36 2Pet 1:10-19 Matthew 17:1-9",
        .Dormition:                 "Luke 1:39-49,56 Phil 2:5-11 Luke 10:38-42,11:27-28",
        .BeheadingOfJohn:           "Matthew 14:1-13 Acts 13:25-32 Mark 6:14-30",

        .SaturdayBeforeExaltation:  "1Cor 2:6-9 Matthew 10:37-11:1 # Saturday before the Universal Elevation",
        .SundayBeforeExaltation:    "Gal 6:11-18 John 3:13-17 # Sunday before the Universal Elevation",
        .SaturdayAfterExaltation:   "1Cor 1:26-29 John 8:21-30 # Saturday after the Universal Elevation",
        .SundayAfterExaltation:     "Gal 2:16-20 Mark 8:34-9:1 # Sunday after the Universal Elevation",
        .SaturdayBeforeNativity:    "Gal 3:8-12 Luke 13:18-29 # Saturday before the Nativity",
        .SundayBeforeNativity:      "Heb 11:9-10,17-23,32-40 Matthew 1:1-25 # Sunday before the Nativity",
        .EveOfNativityOfGod:        "Heb 1:1-12 Luke 2:1-20|Gal 3:15-22 Matthew 13:31-36",
        .SaturdayAfterNativity:     "1Tim 6:11-16 Matthew 12:15-21 # Saturday after the Nativity",
        .SundayAfterNativity:       "Gal 1:11-19 Matthew 2:13-23 # Sunday after the Nativity",
        .SaturdayBeforeTheophany:   "1Tim 3:14-4:5 Matthew 3:1-11 # Saturday before the Theophany",
        .SundayBeforeTheophany:     "2Tim 4:5-8 Mark 1:1-8 # Sunday before the Theophany",
        .EveOfTheophany:            "1Cor 9:19-27 Luke 3:1-18",
        .SaturdayAfterTheophany:    "Ephes 6:10-17 Matthew 4:1-11 # Saturday after the Theophany",
        .SundayAfterTheophany:      "Ephes 4:7-13 Matthew 4:12-17 # Sunday after the Theophany",
        .NewMartyrsConfessorsOfRussia: "Rom 8:28-39 Luke 21:8-19 # Martyrs",
    ]
    
    static let dontTransferReading : [NameOfDay] = [.NewMartyrsConfessorsOfRussia,
        .SundayBeforeNativity, .SaturdayBeforeNativity, .EveOfNativityOfGod, .NativityOfGod, .SundayAfterNativity, .SaturdayAfterNativity,
        .Circumcision,
        .SundayBeforeTheophany, .SaturdayBeforeTheophany, .EveOfTheophany, .Theophany, .SundayAfterTheophany, .SaturdayAfterTheophany,
        .SaturdayBeforeExaltation, .SundayBeforeExaltation, .SaturdayAfterExaltation, .SundayAfterExaltation
    ]

    static let specialAndRegular: [NameOfDay] = [.SaturdayBeforeNativity, .SaturdayAfterNativity, .SaturdayBeforeTheophany, .SaturdayAfterTheophany,
        .SaturdayBeforeExaltation,  .SaturdayAfterExaltation]
    
    static var vigils = [NSDate:String]()
    
    static func GospelOfLent(date: NSDate) -> String {
        let bundle = NSBundle.mainBundle().pathForResource("ReadingLent", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as! [String]

        let dayNum = Cal.d(.SundayOfPublicianAndPharisee) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfJohn(date: NSDate) -> String {
        let bundle = NSBundle.mainBundle().pathForResource("ReadingJohn", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as! [String]
        
        let dayNum = Cal.d(.Pascha) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfMatthew(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]

        let bundleMatthew = NSBundle.mainBundle().pathForResource("ReadingMatthew", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleMatthew!) as! [String]

        var dayNum = (Cal.d(.Pentecost)+1.days) >> date;
        var readings = apostle[dayNum] + " "
        
        if dayNum >= 17*7 {
            NSLog("matt exceeding 17 weeks by \(dayNum-17*7+1) days")
            dayNum = dayNum - 7*7
        }
        
        readings += gospel[dayNum]
        return readings
    }
    
    static func initLukeSpring() {
        LS.PAPSunday = Cal.d(.SundayOfPublicianAndPharisee)
        LS.pentecostPrevYear = Cal.paschaDay(Cal.currentYear-1) + 50.days
        
        let exaltationPrevYear = NSDate(27, 9, Cal.currentYear-1)
        let exaltationPrevYearWeekday = NSDateComponents(date: exaltationPrevYear).weekday
        LS.sundayAfterExaltationPrevYear = exaltationPrevYear + (8-exaltationPrevYearWeekday).days

        let endOfLukeReadings = LS.sundayAfterExaltationPrevYear+112.days
        LS.totalOffset = endOfLukeReadings >> LS.PAPSunday
    }
    
    static func GospelOfLukeSpring(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]
        
        let bundleLuke = NSBundle.mainBundle().pathForResource("ReadingLuke", ofType: "plist")
        let gospelLuke = NSArray(contentsOfFile: bundleLuke!) as! [String]

        let bundleMatthew = NSBundle.mainBundle().pathForResource("ReadingMatthew", ofType: "plist")
        let gospelMatthew = NSArray(contentsOfFile: bundleMatthew!) as! [String]

        var gospelIndex:Int, apostleIndex:Int
        
        let daysFromPentecost = LS.pentecostPrevYear >> date
        let daysFromExaltation = (LS.sundayAfterExaltationPrevYear+1.days) >> date
        let daysBeforePAP = date >> LS.PAPSunday
        
        if daysFromExaltation >= 16*7-1 {

            // need more than three additional Sundays, use 17th week Matthew readings
            if LS.totalOffset > 28 {
                if daysBeforePAP < 21 && daysBeforePAP >= 14 {
                    let indexMatthew = 118 - (daysBeforePAP-14)
                    return apostle[indexMatthew] + " " + gospelMatthew[indexMatthew]

                } else if daysBeforePAP >= 21 {
                    gospelIndex = 118 - daysBeforePAP
                    apostleIndex = 237 - daysBeforePAP
                    return apostle[apostleIndex] + " " + gospelLuke[gospelIndex]
                }
            }
            
            gospelIndex = 111 - daysBeforePAP
            apostleIndex = 230 - daysBeforePAP
            
        } else if daysFromPentecost >= 33*7-1 {
            gospelIndex = daysFromExaltation
            apostleIndex = 230 - daysBeforePAP

        } else {
            gospelIndex = daysFromExaltation
            apostleIndex = daysFromPentecost
        }
        
        return apostle[apostleIndex] + " " + gospelLuke[gospelIndex]
    }

    static func GospelOfLukeFall(date: NSDate) -> String {
        let bundleApostle = NSBundle.mainBundle().pathForResource("ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]
        
        let bundleLuke = NSBundle.mainBundle().pathForResource("ReadingLuke", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleLuke!) as! [String]

        // Sunday of Forefathers: Epistle (29th Sunday), Gospel (28th Sunday)
        if (date == Cal.d(.SundayOfForefathers)) {
            return apostle[202] + " " + gospel[76]
        }
        
        var daysFromPentecost = (Cal.d(.Pentecost)+1.days) >> date
        var daysFromLukeStart = (Cal.d(.SundayAfterExaltation)+1.days) >> date

        // On 29th Sunday borrow Epistle from Sunday of Forefathers
        if (daysFromPentecost == 202) {
            daysFromPentecost = (Cal.d(.Pentecost)+1.days) >> Cal.d(.SundayOfForefathers)
        }
        
        // On 28th Sunday borrow Gospel from Sunday of Forefathers
        if (daysFromLukeStart == 76) {
            daysFromLukeStart = (Cal.d(.SundayAfterExaltation)+1.days) >> Cal.d(.SundayOfForefathers)
        }
        
        return apostle[daysFromPentecost] + " " + gospel[daysFromLukeStart]
    }
    
    static func getRegularReading(date: NSDate) -> String? {
        let exaltation = NSDate(27, 9, Cal.currentYear)
        let exaltationWeekday = NSDateComponents(date: exaltation).weekday
        let exaltationFriOffset = (exaltationWeekday >= 6) ? 13-exaltationWeekday : 6-exaltationWeekday
        let fridayAfterExaltation = exaltation + exaltationFriOffset.days
        
        switch (date) {
        case Cal.d(.StartOfYear) ..< Cal.d(.SundayOfPublicianAndPharisee):
            return GospelOfLukeSpring(date)
            
        case Cal.d(.SundayOfPublicianAndPharisee) ..< Cal.d(.Pascha):
            let reading = GospelOfLent(date)
            return reading.characters.count > 0 ? reading : nil
            
        case Cal.d(.Pascha) ... Cal.d(.Pentecost):
            return GospelOfJohn(date)
            
        case Cal.d(.Pentecost)+1.days ... fridayAfterExaltation:
            return GospelOfMatthew(date)
            
        case Cal.d(.SundayAfterExaltation)+1.days ... Cal.d(.EndOfYear):
            return GospelOfLukeFall(date)
            
        default: return nil
        }
    }

    static func transferReading(date: NSDate) -> NSDate? {
        let weekday = DayOfWeek(rawValue: NSDateComponents(date:date).weekday)
        var newDate:NSDate
        
        if (date > Cal.d(.Pascha) && date < Cal.d(.Pentecost)) {
            return date
        }
        
        if weekday == .Sunday {
            return nil
            
        } else if weekday == .Monday {
            newDate = date + 1.days
            
            if let _ = vigils[newDate] {
                return date
            }
            
        } else {
            newDate = date - 1.days
            if let _ = vigils[newDate] {
                return date + 1.days
            }
        }
        
        return newDate
    }
    
    static func getDailyReading(date: NSDate) -> [String] {
        var readings = [String]()
        var transferred = [NSDate:String]()
        var noRegularReading = false
        var sundayBeforeNativity = false
        
        let formatter = NSDateFormatter()
        formatter.timeStyle = .NoStyle
        formatter.dateFormat = "cccc"
        formatter.locale = NSLocale(localeIdentifier: "en")
        
        Cal.setDate(date)
        initLukeSpring()
        
        vigils = [
            NSDate(30, 1, Cal.currentYear):     "Heb 13:17-21 Luke 6:17-23 # Venerable Anthony",
            NSDate(2, 2, Cal.currentYear):      "Heb 13:17-21 Luke 6:17-23 # Venerable Euthymius",
            NSDate(12, 2, Cal.currentYear):     "Heb 13:7-16 Matthew 5:14-19 # Hierarchs",
            NSDate(6, 5, Cal.currentYear):      "Acts 12:1-11 John 15:17-16:2 # St. George",
            NSDate(21, 5, Cal.currentYear):     "1John 1:1-7 John 19:25-27,21:24-25 # Apostle",
            NSDate(24, 5, Cal.currentYear):     "Heb 7:26-8:2 Matthew 5:14-19 # Equal-to-the Apostles",
            NSDate(28, 7, Cal.currentYear):     "Gal 1:11-19 John 10:1-9 # Equal-to-the Apostles",
            NSDate(1, 8, Cal.currentYear):      "Gal 5:22-6:2 Luke 6:17-23 # Saint",
            NSDate(2, 8, Cal.currentYear):      "James 5:10-20 Luke 4:22-30 # Prophet",
            NSDate(9, 10, Cal.currentYear):     "1John 4:12-19 John 19:25-27,21:24-25 # Repose of the John the Theologian",
            NSDate(26, 11, Cal.currentYear):    "Heb 7:26-8:2 John 10:9-16 # St. John",
            NSDate(18, 12, Cal.currentYear):    "Gal 5:22-6:2 Matthew 11:27-30 # Saint",
            NSDate(19, 12, Cal.currentYear):    "Heb 13:17-21 Luke 6:17-23 # St. Nicholas",
        ]

        for code in Array(specialReadings.keys) where !dontTransferReading.contains(code) {
            if let newDate = transferReading(Cal.d(code)) {
                let oldDate = Cal.d(code)
                let comment = (newDate == oldDate) ? "" : String(format: "# %@ Reading", formatter.stringFromDate(oldDate))
                transferred[newDate] =  String(format: "%@ %@", getRegularReading(oldDate)!, comment)
            }
        }
        
        for (vigilDate, _) in vigils {
            if let newDate = transferReading(vigilDate) {
                let comment = (newDate == vigilDate) ? "" : String(format: "# %@ Reading", formatter.stringFromDate(vigilDate))
                transferred[newDate] = String(format: "%@ %@", getRegularReading(vigilDate)!, comment)
            }
        }
        
        for code in Cal.feastDates[date] ?? [] {
            if code == .SundayBeforeNativity {
                sundayBeforeNativity = true
            }
            
            if Array(specialReadings.keys).contains(code) {
                noRegularReading = true
                
                if (code == .EveOfNativityOfGod) {
                    let choices = specialReadings[code]!.componentsSeparatedByString("|")
                    let weekday = NSDateComponents(date:date).weekday
                    readings.append((weekday == 7 || weekday == 1) ? choices[1] : choices[0])
                    
                } else {
                    readings += [specialReadings[code]!]
                    
                }
            }
        }

        let synaxisTheotokos = Cal.d(.SynaxisTheotokos)
        let synaxisWeekday = DayOfWeek(rawValue: synaxisTheotokos.weekday)
        
        if date == synaxisTheotokos {
            if synaxisWeekday == .Monday {
                return ["Heb 2:11-18 # Theotokos", "Gal 1:11-19 Matthew 2:13-23 # Holy Ancestors"]
                
            } else if synaxisWeekday != .Sunday {
                return ["Heb 2:11-18 Matthew 2:13-23 # Theotokos"]
            }
        }
        
        if date == Cal.d(.SundayAfterNativity) {
            let daysFromExaltation = (LS.sundayAfterExaltationPrevYear+1.days) >> date
            
            if (111-daysFromExaltation >= LS.totalOffset) {
                noRegularReading = false
            }
                        
        } else if Cal.currentWeekday == .Sunday && !sundayBeforeNativity {
            noRegularReading = false
        }
        
        for code in Cal.feastDates[date] ?? [] where specialAndRegular.contains(code) {
            noRegularReading = false
            break
        }
        
        if (noRegularReading) {
            return readings
        }
        
        if let vigilReading = vigils[date] {
            readings += [vigilReading]

            if Cal.currentWeekday != .Sunday {
                return readings + (transferred[date].map { [$0] } ?? [])
            }
        }

        return readings + (getRegularReading(date).map { [$0] } ?? []) + (transferred[date].map { [$0] } ?? [])

    }
        
}
