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

// FYI: http://stackoverflow.com/questions/24116271/whats-the-cleanest-way-of-applying-map-to-a-dictionary-in-swift

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
        let dateComponents = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: date)
        
        self.day = dateComponents.day
        self.month = dateComponents.month
        self.year = dateComponents.year
        self.weekday = dateComponents.weekday
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
    

    static var feastDates = [NSDate: NameOfDay]()
    static var weekDescription = [NSDate: String]()
    
    static func getAttributedDescription(description _descr: String?, color: UIColor) -> NSMutableAttributedString {
        if let descr = _descr {
            var attrs = [NSForegroundColorAttributeName: color]
            return NSMutableAttributedString(string: descr, attributes: attrs)
            
        } else {
            return NSMutableAttributedString(string: "");
        }
    }
    
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
            let pascha = day[0].toDate()

            if feastDates[pascha] == nil {
                feastDates += [pascha: .Pascha]
                
                // generate calendar for entire year
                palmSunday(year)
                ascensionDay(year)
                pentecostDay(year)
                greatFeasts(year)
                
                // for calculation of week number
                generateSundayTitles(year)
            }
            
            return pascha
            
        } else {
            return nil
        }
    }
    
    enum NameOfDay: Int {
        case Pascha=0, Pentecost, Ascension, PalmSunday, NativityOfGod, Circumcision, EveOfTheophany, Theophany, MeetingOfLord, Annunciation, NativityOfJohn, PeterAndPaul, Transfiguration, Dormition, BeheadingOfJohn, NativityOfTheotokos, ExaltationOfCross, Veil, EntryIntoTemple, StNicholas
    }

    static let feastStrings : [NameOfDay: String] = [
        .Pascha: "PASCHA. The Bright and Glorious Resurrection of our Lord, God, and Saviour Jesus Christ",
        .Pentecost: "Pentecost. Sunday of the Holy Trinity. Descent of the Holy Spirit on the Apostles",
        .Ascension: "Ascension of our Lord, God, and Saviour Jesus Christ",
        .PalmSunday: "Palm Sunday. Entrance of our Lord into Jerusalem",
        .NativityOfGod : "The Nativity of our Lord God and Savior Jesus Christ",
        .Circumcision: "Circumcision of our Lord",
        .EveOfTheophany: "Eve of Theophany",
        .Theophany: "Holy Theophany: the Baptism of Our Lord, God, and Saviour Jesus Christ",
        .MeetingOfLord: "The Meeting of our Lord, God, and Saviour Jesus Christ in the Temple",
        .Annunciation: "The Annunciation of our Most Holy Lady, Theotokos and Ever-Virgin Mary",
        .NativityOfJohn: "Nativity of the Holy Glorious Prophet, Forerunner, and Baptist of the Lord, John",
        .PeterAndPaul: "The Holy Glorious and All-Praised Leaders of the Apostles, Peter and Paul",
        .Transfiguration: "The Holy Transfiguration of Our Lord God and Saviour Jesus Christ",
        .Dormition: "The Dormition (Repose) of our Most Holy Lady Theotokos and Ever-Virgin Mary",
        .BeheadingOfJohn: "The Beheading of the Holy Glorious Prophet, Forerunner and Baptist of the Lord, John",
        .NativityOfTheotokos: "Nativity of Our Most Holy Lady Theotokos and Ever-Virgin Mary",
        .ExaltationOfCross: "The Universal Exaltation of the Precious and Life-Giving Cross",
        .Veil: "Protection of Our Most Holy Lady Theotokos and Ever-Virgin Mary",
        .EntryIntoTemple: "Entry into the Temple of our Most Holy Lady Theotokos and Ever-Virgin Mary",
        .StNicholas: "St. Nicholas the Wonderworker"
        
    ]
    
    static func greatFeasts(year: Int) -> [ NSDate ] {
        let feasts : [NSDate: NameOfDay] = [
            NSDateComponents(day: 7, month: 1, year: year).toDate():    .NativityOfGod,
            NSDateComponents(day: 14, month: 1, year: year).toDate():   .Circumcision,
            NSDateComponents(day: 18, month: 1, year: year).toDate():   .EveOfTheophany,
            NSDateComponents(day: 19, month: 1, year: year).toDate():   .Theophany,
            NSDateComponents(day: 15, month: 2, year: year).toDate():   .MeetingOfLord,
            NSDateComponents(day: 7, month: 4, year: year).toDate():    .Annunciation,
            NSDateComponents(day: 7, month: 7, year: year).toDate():    .NativityOfJohn,
            NSDateComponents(day: 12, month: 7, year: year).toDate():   .PeterAndPaul,
            NSDateComponents(day: 19, month: 8, year: year).toDate():   .Transfiguration,
            NSDateComponents(day: 28, month: 8, year: year).toDate():   .Dormition,
            NSDateComponents(day: 11, month: 9, year: year).toDate():   .BeheadingOfJohn,
            NSDateComponents(day: 21, month: 9, year: year).toDate():   .NativityOfTheotokos,
            NSDateComponents(day: 27, month: 9, year: year).toDate():   .ExaltationOfCross,
            NSDateComponents(day: 14, month: 10, year: year).toDate():  .Veil,
            NSDateComponents(day: 4, month: 12, year: year).toDate():   .EntryIntoTemple,
            NSDateComponents(day: 19, month: 12, year: year).toDate():  .StNicholas
        ]
        
        feastDates += feasts
        return Array(feasts.keys)
    }
    
    static func pentecostDay(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var pentecost = pascha + 49.days
            feastDates +=  [pentecost: .Pentecost]
            return pentecost
            
        } else {
            return nil
        }
    }
    
    static func ascensionDay(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var ascension = pascha + 39.days
            feastDates +=  [ascension: .Ascension]
            return ascension
            
        } else {
            return nil
        }
    }
    
    static func palmSunday(year: Int) -> NSDate? {
        if let pascha = paschaDay(year) {
            var palmSunday = pascha - 7.days
            feastDates += [palmSunday: .PalmSunday]
            return palmSunday
            
        } else {
            return nil
        }
    }
    
    static func getDayDescription(date: NSDate) -> String? {
        let dateComponents = NSDateComponents(date: date)

        if let _ = paschaDay(dateComponents.year) {
            if let feastCode = feastDates[date] {
                return feastStrings[feastCode]
            }
        }
        
        return nil
    }
    
    static func generateSundayTitles(year: Int)  {
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
            let dayOfWeek = (dateComponents.weekday == 1) ? "Sunday" : "Week"
            
            switch (date) {
                
            case startOfYear ... lentBegin-22.days:
                return (pentecostPrev != nil) ?  "\(dayOfWeek) \((pentecostPrev!+1.days) >> date) after Pentecost" : nil
                
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
                return "\(dayOfWeek) \((pentecost+1.days) >> date) after Pentecost"
                
            default: return nil
            }
            
        }
        
        return nil
    }
    
    static func getToneDescription(date: NSDate) -> NSString? {
        func toneFromOffset(offset: Int) -> Int {
            let reminder = (offset - 1) % 8
            return (reminder == 0) ? 8 : reminder
        }
        
        let dateComponents = NSDateComponents(date: date)
        
        if let pascha = paschaDay(dateComponents.year) {
            let startOfYear = NSDateComponents(day: 1, month: 1, year: dateComponents.year).toDate()
            let endOfYear = NSDateComponents(day: 31, month: 12, year: dateComponents.year).toDate()
            let palmSunday = pascha - 7.days
            let prevPascha = paschaDay(dateComponents.year-1)
            let afterAntiPascha = pascha + 8.days
            
            switch (date) {
            case startOfYear ..< palmSunday: return (prevPascha != nil) ? "Tone \(toneFromOffset(prevPascha! >> date))" : nil
            case afterAntiPascha ... endOfYear: return "Tone \(toneFromOffset(pascha >> date))"
            default: return nil
            }
        }
        
        return nil
    }
    
    enum FastingType {
        case NoFast, Vegetarian, FishAllowed, FastFree, Cheesefare
    }
    
    static func getFastingDescription(date: NSDate) -> (FastingType, NSString)? {
        let dateComponents = NSDateComponents(date: date)
        let year = dateComponents.year
        let weekday = dateComponents.weekday
        
        if let pascha = paschaDay(year) {
            let nativityOfGod = NSDateComponents(day: 7, month: 1, year: year).toDate()
            let annunciation = NSDateComponents(day: 7, month: 4, year: year).toDate()
            let nativityJohnForerunner = NSDateComponents(day: 7, month: 7, year: year).toDate()
            let transfiguration = NSDateComponents(day: 19, month: 8, year: year).toDate()
            let entryIntoTemple = NSDateComponents(day: 4, month: 12, year: year).toDate()
            let stNicholas = NSDateComponents(day: 19, month: 12, year: year).toDate()
            
            let eveOfTheophany = NSDateComponents(day: 18, month: 1, year: year).toDate()
            let beheadingOfJohn = NSDateComponents(day: 11, month: 9, year: year).toDate()
            let exhaltationOfCross = NSDateComponents(day: 27, month: 9, year: year).toDate()

            let startOfYear = NSDateComponents(day: 1, month: 1, year: dateComponents.year).toDate()

            let greatLentStart = pascha - 48.days
            let palmSunday = pascha - 7.days
            let pentecost = pentecostDay(year)!
            let apostolesDay = NSDateComponents(day: 12, month: 7, year: year).toDate()

            let dormitionFastStart = NSDateComponents(day: 14, month: 8, year: year).toDate()
            let dormitionDay = NSDateComponents(day: 28, month: 8, year: year).toDate()
            
            let nativityFastStart = NSDateComponents(day: 28, month: 11, year: year).toDate()
            let endOfYear = NSDateComponents(day: 31, month: 12, year: dateComponents.year).toDate()

            // TODO: what is fast on a common day (fasting seasons, Wed/Fri fast)
            
            if let code = feastDates[date] {
                switch code {
                    
                case .Theophany,
                     .MeetingOfLord:
                    return (.FastFree, "No fast")
                    
                case .NativityOfTheotokos,
                     .PeterAndPaul,
                     .Dormition,
                     .Veil:
                    return (weekday == 4 || weekday == 6) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")

                case .NativityOfJohn,
                     .Transfiguration,
                     .EntryIntoTemple,
                     .StNicholas:
                    return (.FishAllowed, "Fish Allowed")
                    
                case .EveOfTheophany,
                     .BeheadingOfJohn,
                     .ExaltationOfCross:
                    return (.Vegetarian, "Vegetarian")
                
                default: break
                    
                }
            }
            
            switch (date) {
                
            case startOfYear:
                return (weekday == 7 || weekday == 1) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
                
            case startOfYear+1.days ..< nativityOfGod:
                return (.Vegetarian, "Nativity Fast")
                
            case nativityOfGod ..< eveOfTheophany:
                return (.FastFree, "Svyatki")

            case greatLentStart-21.days ... greatLentStart-15.days:
                return (.FastFree, "Fast-free week")

            case greatLentStart-7.days ... greatLentStart-1.days:
                return (.Cheesefare, "Maslenitsa")
                
            case greatLentStart ... palmSunday:
                return (date == annunciation) ? (.FishAllowed, "Fish allowed") : (.Vegetarian, "Great Lent")
                
            case palmSunday + 1.days ..< pascha:
                return (.Vegetarian, "Vegetarian")
                
            case pascha ..< pascha + 7.days:
                return (.FastFree, "Fast-free week")
                
            case pentecost+1.days ... pentecost+7.days:
                return (.FastFree, "Fast-free week")
                
            case pentecost+8.days ... apostolesDay-1.days:
                return (weekday == 2 || weekday == 4 || weekday == 6) ? (.Vegetarian, "Apostoles' Fast") : (.FishAllowed, "Apostoles' Fast")
                
                
            case dormitionFastStart ... dormitionDay-1.days:
                return (.Vegetarian, "Dormition Fast")
                
            case nativityFastStart ..< stNicholas:
                return (weekday == 2 || weekday == 4 || weekday == 6) ? (.Vegetarian, "Nativity Fast") : (.FishAllowed, "Nativity Fast")
                
            case stNicholas ... endOfYear:
                return (weekday == 7 || weekday == 1) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")


            default: return nil
            }
        }
        
        return nil
    }
    
    static func printFeastDescription() {
        // get Pascha day to trigger calendar initialization
        let dateComponents = NSDateComponents(date: NSDate())
        let _ = paschaDay(dateComponents.year)
        
        for (date, code) in feastDates {
            let date_str = formatter.stringFromDate(date)
            println("\(date_str) \(feastStrings[code])")
        }
    }
    
}


//let dc = NSDateComponents(day: 31, month: 12, year: 2014)
let dc = NSDateComponents(date: NSDate())


//FeastCalendar.getWeekDescription(dc.toDate())






