// Playground - noun: a place where people can play

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
    
    func toDate() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        return calendar.dateFromComponents(self)!
    }
}

func += <KeyType, ValueType> (inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right { left.updateValue(v, forKey: k) }
}

struct FeastCalendar {

    static var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
        }()
    
    static var feastDescription = [NSDate: String]()
    
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
            feastDescription += [day[0].toDate(): "PASCHA. The Bright and Glorious Resurrection of our Lord, God, and Saviour Jesus Christ"]
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
    
    static func getFeasts(year: Int) -> [ NSDate ] {
        
        var feast : NSDateComponents
        var arr : [ NSDate ] = []
        
        if let pascha = paschaDay(year) {
            arr += [palmSunday(year)!, pascha, ascensionDay(year)!, pentecostDay(year)!]
            arr += greatFeasts(year)
            
            arr.sort { d1, d2 in return d1.compare(d2) == NSComparisonResult.OrderedAscending }
        }
        
        return arr
    }
    
    static func getFeastDescription(year: Int) {
        let feasts = getFeasts(year)
        
        for feast in feasts {
            let date_str = formatter.stringFromDate(feast)
            let feast_str = feastDescription[feast]
            println("\(date_str) \(feast_str)")
        }
    }

}

FeastCalendar.getFeastDescription(2015)



