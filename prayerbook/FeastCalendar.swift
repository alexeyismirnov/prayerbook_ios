//
//  FeastCalendar.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/10/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit


enum TimeIntervalUnit {
    case Seconds, Minutes, Hours, Days, Months, Years
    
    func dateComponents(interval: Int) -> NSDateComponents {
        var components:NSDateComponents = NSDateComponents()
        
        switch (self) {
        case .Seconds:
            components.second = interval
        case .Minutes:
            components.minute = interval
        case .Days:
            components.day = interval
        case .Months:
            components.month = interval
        case .Years:
            components.year = interval
        default:
            components.day = interval
        }
        return components
    }
}

struct TimeInterval {
    var interval: Int
    var unit: TimeIntervalUnit
    
    init(interval: Int, unit: TimeIntervalUnit) {
        self.interval = interval
        self.unit = unit
    }
}

extension Int {
    var days: TimeInterval {
        return TimeInterval(interval: self, unit: TimeIntervalUnit.Days);
    }
}

func - (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    var components = right.unit.dateComponents(-right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: nil)!
}

func + (let left:NSDate, let right:TimeInterval) -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    var components = right.unit.dateComponents(right.interval)
    return calendar.dateByAddingComponents(components, toDate: left, options: nil)!
}

extension NSDateComponents {
    convenience init(day: Int, month:Int, year: Int) {
        self.init()
        
        self.day = day
        self.month = month
        self.year = year
    }
    
    convenience init(date: NSDate) {
        self.init()
        
        let calendar = NSCalendar.currentCalendar()
        let dateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: date)
        
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
    }
    
    func toDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateFromComponents(self)!
    }
}

func + (str: String, date: NSDate) -> String {
    var formatter = NSDateFormatter()
    formatter.dateStyle = .ShortStyle
    formatter.timeStyle = .NoStyle
    
    return formatter.stringFromDate(date)
}

func + (arg1: NSMutableAttributedString, arg2: NSMutableAttributedString) -> NSMutableAttributedString {
    var result = NSMutableAttributedString(attributedString: arg1)
    result.appendAttributedString(arg2)
    return result
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right { left.updateValue(v, forKey: k) }
}

extension NSDate: Comparable {
    
}

public func < (let left:NSDate, let right: NSDate) -> Bool {
    var result:NSComparisonResult = left.compare(right)
    return (result == .OrderedAscending)
}

public func == (let left:NSDate, let right: NSDate) -> Bool {
    var result:NSComparisonResult = left.compare(right)
    return (result == .OrderedSame)
}


func >> (left: NSDate, right: NSDate) -> Int {
    let calendar = NSCalendar.currentCalendar()
    let components = calendar.components(.CalendarUnitDay, fromDate: left, toDate: right, options: nil)
    
    return components.day/7 + 1
}

struct FeastCalendar {
    
    static var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
        }()
    
    static var feastDescription = [NSDate: String]()
    static var weekDescription = [NSDate: String]()
    
    static func paschaDay(year: Int) -> NSDate? {
        
        let _paschaDay = [
            NSDateComponents(day: 4,  month: 4, year: 2010),
            NSDateComponents(day: 24, month: 4, year: 2011),
            NSDateComponents(day: 15, month: 4, year: 2012),
            NSDateComponents(day: 5,  month: 5, year: 2013),
            NSDateComponents(day: 20, month: 4, year: 2014),
            NSDateComponents(day: 12, month: 4, year: 2015),
            NSDateComponents(day: 1,  month: 5, year: 2016),
            NSDateComponents(day: 16, month: 4, year: 2017),
            NSDateComponents(day: 8,  month: 4, year: 2018),
            NSDateComponents(day: 28, month: 4, year: 2019),
            NSDateComponents(day: 19, month: 4, year: 2020)
        ]
        
        var day = _paschaDay.filter { $0.year == year}
        if day.count > 0 {
            
            if feastDescription[day[0].toDate()] == nil {
                feastDescription += [day[0].toDate(): "PASCHA. The Bright and Glorious Resurrection of our Lord, God, and Saviour Jesus Christ"]
                
                // generate calendar for entire year
                palmSunday(year)
                ascensionDay(year)
                pentecostDay(year)
                greatFeasts(year)
                
                // for calculation of week number
                generateSundayTitles(year)
            }
            
            return day[0].toDate()
            
        } else {
            return nil
        }
    }
    
    static func greatFeasts(year: Int) -> [ NSDate ] {
        let feasts = [
            NSDateComponents(day: 7, month: 1, year: year).toDate(): "The Nativity of our Lord God and Savior Jesus Christ",
            NSDateComponents(day: 14, month: 1, year: year).toDate(): "Circumcision of our Lord",
            NSDateComponents(day: 19, month: 1, year: year).toDate(): "Holy Theophany: the Baptism of Our Lord, God, and Saviour Jesus Christ",
            NSDateComponents(day: 15, month: 2, year: year).toDate(): "The Meeting of our Lord, God, and Saviour Jesus Christ in the Temple",
            NSDateComponents(day: 7, month: 4, year: year).toDate(): "The Annunciation of our Most Holy Lady, Theotokos and Ever-Virgin Mary",
            NSDateComponents(day: 7, month: 7, year: year).toDate(): "Nativity of the Holy Glorious Prophet, Forerunner, and Baptist of the Lord, John",
            NSDateComponents(day: 12, month: 7, year: year).toDate(): "The Holy Glorious and All-Praised Leaders of the Apostles, Peter and Paul",
            NSDateComponents(day: 19, month: 8, year: year).toDate(): "The Holy Transfiguration of Our Lord God and Saviour Jesus Christ",
            NSDateComponents(day: 28, month: 8, year: year).toDate(): "The Dormition (Repose) of our Most Holy Lady Theotokos and Ever-Virgin Mary",
            NSDateComponents(day: 11, month: 9, year: year).toDate(): "The Beheading of the Holy Glorious Prophet, Forerunner and Baptist of the Lord, John",
            NSDateComponents(day: 21, month: 9, year: year).toDate(): "Nativity of Our Most Holy Lady Theotokos and Ever-Virgin Mary",
            NSDateComponents(day: 27, month: 9, year: year).toDate(): "The Universal Exaltation of the Precious and Life-Giving Cross",
            NSDateComponents(day: 14, month: 10, year: year).toDate(): "Protection of Our Most Holy Lady Theotokos and Ever-Virgin Mary",
            NSDateComponents(day: 4, month: 12, year: year).toDate(): "Entry into the Temple of our Most Holy Lady Theotokos and Ever-Virgin Mary"
        ]
        
        feastDescription += feasts
        return Array(feasts.keys)
    }
    
    static func pentecostDay(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var pentecost = pascha + 49.days
            feastDescription +=  [pentecost: "Pentecost. Sunday of the Holy Trinity. Descent of the Holy Spirit on the Apostles"]
            return pentecost
            
        } else {
            return nil
        }
    }
    
    static func ascensionDay(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var ascension = pascha + 39.days
            feastDescription +=  [ascension: "Ascension of our Lord, God, and Saviour Jesus Christ"]
            return ascension
            
        } else {
            return nil
        }
    }
    
    static func palmSunday(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var palmSunday = pascha - 7.days
            feastDescription += [palmSunday: "Palm Sunday. Entrance of our Lord into Jerusalem"]
            return palmSunday
            
        } else {
            return nil
        }
    }
    
    static func getDayDescription(date: NSDate) -> String? {
        let dateComponents = NSDateComponents(date: date)
        if let _ = paschaDay(dateComponents.year) {
            return feastDescription[date]
        }
        
        return nil
    }
    
    static func getAttributedDayDescription(date: NSDate) -> NSMutableAttributedString {
        var result = NSMutableAttributedString(string: "")
        
        if let descr = getDayDescription(date) {
            var attrs = [NSForegroundColorAttributeName: UIColor.redColor()]
            var infoTxt = NSMutableAttributedString(string: descr, attributes: attrs)
            result.appendAttributedString(infoTxt)
        }
        
        return result
    }
    
    static func generateSundayTitles(year: Int) -> String {
        if let pascha = paschaDay(year) {
            let lentBegin = pascha - 48.days
            
            weekDescription += [lentBegin-29.days: "Zacchæus’s Sunday"]
            weekDescription += [lentBegin-22.days: "Sunday of the Publican and the Pharisee"]
            weekDescription += [lentBegin-15.days: "Sunday of the Prodigal Son"]
            weekDescription += [lentBegin-8.days: "Sunday of the Dread Judgement"]
            weekDescription += [lentBegin-1.days: "Forgiveness Sunday"]
            
            weekDescription += [lentBegin: "Beginning of Great Lent" ]
            weekDescription += [lentBegin+6.days: "1st Sunday of Lent: Triumph of Orthodoxy" ]
            weekDescription += [lentBegin+13.days: "2nd Sunday of Lent; Saint Gregory Palamas" ]
            weekDescription += [lentBegin+20.days: "3rd Sunday of Lent, Veneration of the Precious Cross" ]
            weekDescription += [lentBegin+27.days: "4th Sunday of Lent; Venerable John Climacus of Sinai" ]
            weekDescription += [lentBegin+34.days: "5th Sunday of Lent; Venerable Mary of Egypt" ]
            weekDescription += [lentBegin+40.days: "Lazarus Saturday"]
            
            weekDescription += [pascha+7.days: "2nd Sunday after Pascha. Antipascha"]
            weekDescription += [pascha+14.days: "3rd Sunday after Pascha. Sunday of the Myrrhbearing Women"]
            weekDescription += [pascha+21.days: "4th Sunday after Pascha. Sunday of the Paralytic"]
            weekDescription += [pascha+28.days: "5th Sunday after Pascha. Sunday of the Samaritan Woman"]
            weekDescription += [pascha+35.days: "6th Sunday after Pascha. Sunday of the Blind Man"]
            weekDescription += [pascha+42.days: "7th Sunday after Pascha. Commemoration of the Holy Fathers of the First Ecumenical Council"]
        }
        
        return "bug in Playground"
    }
    
    
    static func getWeekDescription(date: NSDate) -> NSString? {
        
        let dateComponents = NSDateComponents(date: date)
        if let pascha = paschaDay(dateComponents.year) {
            if let descr = weekDescription[date] {
                return descr
            }
            
            let lentBegin = pascha - 48.days
            let palmSunday = pascha - 7.days
            let antiPascha = pascha + 7.days
            let pentecost = pentecostDay(dateComponents.year)!
            let pentecostPrev = pentecostDay(dateComponents.year-1)
            
            let startOfYear = NSDateComponents(day: 1, month: 1, year: dateComponents.year).toDate()
            let endOfYear = NSDateComponents(day: 31, month: 12, year: dateComponents.year).toDate()
            
            switch (date) {
                
            case startOfYear ... lentBegin-22.days:
                return (pentecostPrev != nil) ?  "Week \((pentecostPrev!+1.days) >> date) after Pentecost" : nil
                
            case lentBegin-21.days ... lentBegin-15.days:
                return "Week of the Publican and the Pharisee"
                
            case lentBegin-14.days ... lentBegin-8.days:
                return "Week of the Prodigal Son"
                
            case lentBegin-7.days ... lentBegin:
                return "Week of the Dread Judgement"
                
            case lentBegin..<palmSunday:
                return "Week \(lentBegin >> date) of Great Lent"
                
            case palmSunday+1.days ..< pascha:
                return "Passion Week"
                
            case pascha+1.days ... antiPascha:
                return "Bright Week"
                
            case antiPascha..<pentecost:
                return "Week \(pascha >> date) after Pascha"
                
            case pentecost+1.days ... endOfYear:
                return "Week \((pentecost+1.days) >> date) after Pentecost"
                
            default: return nil
            }
            
        }
        
        return nil
    }
    
    static func getAttributedWeekDescription(date: NSDate) -> NSMutableAttributedString {
        var result = NSMutableAttributedString(string: "")
        
        if let descr = getWeekDescription(date) {
            var attrs = [NSForegroundColorAttributeName: UIColor.grayColor()]
            var infoTxt = NSMutableAttributedString(string: descr, attributes: attrs)
            result.appendAttributedString(infoTxt)
        }
        
        return result
    }
    
    static func printFeastDescription() {
        // get Pascha day to trigger calendar initialization
        let dateComponents = NSDateComponents(date: NSDate())
        let _ = paschaDay(dateComponents.year)
        
        for (date, descr) in feastDescription {
            let date_str = formatter.stringFromDate(date)
            println("\(date_str) \(descr)")
        }
    }
    
}
