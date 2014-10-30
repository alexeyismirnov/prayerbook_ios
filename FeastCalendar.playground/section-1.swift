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
    convenience init(_ day: Int, _ month:Int, _ year: Int) {
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

func + (arg1: NSMutableAttributedString?, arg2: NSMutableAttributedString?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            var result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(rightArg)
            return result
            
        } else {
            return arg2
        }
        
    } else {
        return arg1
    }
    
}

func + (arg1: NSMutableAttributedString?, arg2: String?) -> NSMutableAttributedString? {
    
    if let rightArg = arg2 {
        if let leftArg = arg1 {
            var result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg)
        }
        
    } else {
        return arg1
    }
}

func + (arg1: NSMutableAttributedString?, arg2: (String?, UIColor)) -> NSMutableAttributedString? {
    
    if let rightArg = arg2.0 {
        if let leftArg = arg1 {
            var result = NSMutableAttributedString(attributedString: leftArg)
            result.appendAttributedString(NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1]))
            return result
            
        } else {
            return NSMutableAttributedString(string: rightArg, attributes: [NSForegroundColorAttributeName: arg2.1])
        }
        
    } else {
        return arg1
    }
}

func += <K,V> (inout left: Dictionary<K, [V]>, right: Dictionary<K, [V]>) {
    for (k, v) in right {
        if let leftValue = left[k] {
            left.updateValue(v + leftValue, forKey: k)
        } else {
            left.updateValue(v, forKey: k)
        }
    }
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
    
    static var currentYear : Int = 0
    static var feastDates = [NSDate: [NameOfDay]]()
    
    static func d(code: NameOfDay, _ year:Int = currentYear) -> NSDate {
        var res = filter(FeastCalendar.feastDates, { (date, codes) in return contains(codes, code) && NSDateComponents(date:date).year == year } )
        return res[0].0
    }
    
    static func paschaDay(year: Int) -> NSDate {
        // http://calendar.lenacom.spb.ru/index.php
        let a = (19*(year%19) + 15) % 30
        let b = (2*(year%4) + 4*(year%7) + 6*a + 6) % 7
        let pascha = ((a+b > 10) ? NSDateComponents(a+b-9, 4, year).toDate() : NSDateComponents(22+a+b, 3, year).toDate()) + 13.days
        
        if feastDates[pascha] == nil {
            feastDates += [pascha: [.Pascha]]
            generateFeasts(year)
        }
        
        return pascha
    }
    
    enum NameOfDay: Int {
        case Pascha=0, Pentecost, Ascension, PalmSunday, NativityOfGod, Circumcision, EveOfTheophany, Theophany, MeetingOfLord, Annunciation, NativityOfJohn, PeterAndPaul, Transfiguration, Dormition, BeheadingOfJohn, NativityOfTheotokos, ExaltationOfCross, Veil, EntryIntoTemple, StNicholas, BeginningOfGreatLent, StartOfYear, EndOfYear, ZacchaeusSunday, SundayOfPublicianAndPharisee, SundayOfProdigalSon, SundayOfDreadJudgement, ForgivenessSunday, FirstSundayOfGreatLent, SecondSundayOfGreatLent, ThirdSundayOfGreatLent, FourthSundayOfGreatLent, FifthSundayOfGreatLent, LazarusSaturday, SecondSundayAfterPascha, ThirdSundayAfterPascha, FourthSundayAfterPascha, FifthSundayAfterPascha, SixthSundayAfterPascha, SeventhSundayAfterPascha, BeginningOfDormitionFast, BeginningOfNativityFast
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
        .StNicholas: "St. Nicholas the Wonderworker",
        .ZacchaeusSunday: "Zacchæus’s Sunday",
        .SundayOfPublicianAndPharisee: "Sunday of the Publican and the Pharisee",
        .SundayOfProdigalSon: "Sunday of the Prodigal Son",
        .SundayOfDreadJudgement: "Sunday of the Dread Judgement",
        .ForgivenessSunday: "Forgiveness Sunday",
        .BeginningOfGreatLent: "Beginning of Great Lent",
        .FirstSundayOfGreatLent: "1st Sunday of Lent: Triumph of Orthodoxy",
        .SecondSundayOfGreatLent: "2nd Sunday of Lent; Saint Gregory Palamas",
        .ThirdSundayOfGreatLent: "3rd Sunday of Lent, Veneration of the Precious Cross",
        .FourthSundayOfGreatLent: "4th Sunday of Lent; Venerable John Climacus of Sinai",
        .FifthSundayOfGreatLent: "5th Sunday of Lent; Venerable Mary of Egypt",
        .LazarusSaturday: "Lazarus Saturday",
        .SecondSundayAfterPascha: "2nd Sunday after Pascha. Antipascha",
        .ThirdSundayAfterPascha: "3rd Sunday after Pascha. Sunday of the Myrrhbearing Women",
        .FourthSundayAfterPascha: "4th Sunday after Pascha. Sunday of the Paralytic",
        .FifthSundayAfterPascha: "5th Sunday after Pascha. Sunday of the Samaritan Woman",
        .SixthSundayAfterPascha: "6th Sunday after Pascha. Sunday of the Blind Man",
        .SeventhSundayAfterPascha: "7th Sunday after Pascha. Commemoration of the Holy Fathers of the First Ecumenical Council",
        .BeginningOfDormitionFast: "Beginning of Dormition fast",
        .BeginningOfNativityFast:  "Beginning of Nativity fast"
    ]
    
    static let greatFeastCodes : [NameOfDay] = [.PalmSunday, .Pascha, .Ascension, .Pentecost, .NativityOfGod, .Circumcision, .Theophany, .MeetingOfLord, .Annunciation, .NativityOfJohn, .PeterAndPaul, .Transfiguration, .Dormition, .BeheadingOfJohn, .NativityOfTheotokos, .ExaltationOfCross, .Veil, .EntryIntoTemple]
    
    static func generateFeasts(year: Int) {
        let pascha = paschaDay(year)
        let greatLentBegin = pascha-48.days
        
        let movingFeasts : [NSDate: [NameOfDay]] = [
            greatLentBegin-29.days:                   [.ZacchaeusSunday],
            greatLentBegin-22.days:                   [.SundayOfPublicianAndPharisee],
            greatLentBegin-15.days:                   [.SundayOfProdigalSon],
            greatLentBegin-8.days:                    [.SundayOfDreadJudgement],
            greatLentBegin-1.days:                    [.ForgivenessSunday],
            greatLentBegin:                           [.BeginningOfGreatLent],
            greatLentBegin+6.days:                    [.FirstSundayOfGreatLent],
            greatLentBegin+13.days:                   [.SecondSundayOfGreatLent],
            greatLentBegin+20.days:                   [.ThirdSundayOfGreatLent],
            greatLentBegin+27.days:                   [.FourthSundayOfGreatLent],
            greatLentBegin+34.days:                   [.FifthSundayOfGreatLent],
            greatLentBegin+40.days:                   [.LazarusSaturday],
            pascha-7.days:                            [.PalmSunday],
            pascha+7.days:                            [.SecondSundayAfterPascha],
            pascha+14.days:                           [.ThirdSundayAfterPascha],
            pascha+21.days:                           [.FourthSundayAfterPascha],
            pascha+28.days:                           [.FifthSundayAfterPascha],
            pascha+35.days:                           [.SixthSundayAfterPascha],
            pascha+39.days:                           [.Ascension],
            pascha+42.days:                           [.SeventhSundayAfterPascha],
            pascha+49.days:                           [.Pentecost],
        ]
        
        let fixedFeasts : [NSDate: [NameOfDay]] = [
            NSDateComponents(1,  1, year).toDate():   [.StartOfYear],
            NSDateComponents(7,  1, year).toDate():   [.NativityOfGod],
            NSDateComponents(14, 1, year).toDate():   [.Circumcision],
            NSDateComponents(18, 1, year).toDate():   [.EveOfTheophany],
            NSDateComponents(19, 1, year).toDate():   [.Theophany],
            NSDateComponents(15, 2, year).toDate():   [.MeetingOfLord],
            NSDateComponents(7,  4, year).toDate():   [.Annunciation],
            NSDateComponents(7,  7, year).toDate():   [.NativityOfJohn],
            NSDateComponents(12, 7, year).toDate():   [.PeterAndPaul],
            NSDateComponents(14, 8, year).toDate():   [.BeginningOfDormitionFast],
            NSDateComponents(19, 8, year).toDate():   [.Transfiguration],
            NSDateComponents(28, 8, year).toDate():   [.Dormition],
            NSDateComponents(11, 9, year).toDate():   [.BeheadingOfJohn],
            NSDateComponents(21, 9, year).toDate():   [.NativityOfTheotokos],
            NSDateComponents(27, 9, year).toDate():   [.ExaltationOfCross],
            NSDateComponents(14, 10, year).toDate():  [.Veil],
            NSDateComponents(28, 11, year).toDate():  [.BeginningOfNativityFast],
            NSDateComponents(4,  12, year).toDate():  [.EntryIntoTemple],
            NSDateComponents(19, 12, year).toDate():  [.StNicholas],
            NSDateComponents(31, 12, year).toDate():  [.EndOfYear],
        ];
        
        feastDates += movingFeasts
        feastDates += fixedFeasts
    }
    
    static func isGreatFeast(date: NSDate) -> Bool {
        let dateComponents = NSDateComponents(date: date)
        let _ = paschaDay(dateComponents.year)
        
        if let feastCodes = feastDates[date] {
            for code in feastCodes {
                if contains(greatFeastCodes, code) {
                    return true
                }
            }
        }
        return false
    }
    
    static func getDayDescription(date: NSDate) -> NSMutableAttributedString? {
        let dateComponents = NSDateComponents(date: date)
        let _ = paschaDay(dateComponents.year)
        var result : NSMutableAttributedString? = nil
        
        if let feastCodes = feastDates[date] {
            for code in feastCodes {
                if let feastStr = feastStrings[code] {
                    result = result + (feastStr, contains(greatFeastCodes, code) ? UIColor.redColor() : UIColor.grayColor())
                    result = result + "\n"
                }
            }
        }
        
        return result
    }
    
    static func getWeekDescription(date: NSDate) -> NSString? {
        let dateComponents = NSDateComponents(date: date)
        
        currentYear = dateComponents.year
        let pascha = paschaDay(currentYear)
        let prevPascha = paschaDay(currentYear-1)
        let dayOfWeek = (dateComponents.weekday == 1) ? "Sunday" : "Week"
        
        switch (date) {
        case d(.StartOfYear) ..< d(.SundayOfPublicianAndPharisee):
            return  "\(dayOfWeek) \((d(.Pentecost, currentYear-1)+1.days) >> date) after Pentecost"
            
        case d(.SundayOfPublicianAndPharisee)+1.days ..< d(.SundayOfProdigalSon):
            return "Week of the Publican and the Pharisee"
            
        case d(.SundayOfProdigalSon)+1.days ..< d(.SundayOfDreadJudgement):
            return "Week of the Prodigal Son"
            
        case d(.SundayOfDreadJudgement)+1.days ..< d(.BeginningOfGreatLent):
            return "Week of the Dread Judgement"
            
        case d(.BeginningOfGreatLent) ..< d(.PalmSunday):
            return (dateComponents.weekday == 1) ? nil : "Week \(d(.BeginningOfGreatLent) >> date) of Great Lent"
            
        case d(.PalmSunday)+1.days ..< pascha:
            return "Passion Week"
            
        case pascha+1.days ..< d(.SecondSundayAfterPascha):
            return "Bright Week"
            
        case d(.SecondSundayAfterPascha)+1.days ..< d(.Pentecost):
            return (dateComponents.weekday == 1) ? nil : "Week \(pascha >> date) after Pascha"
            
        case d(.Pentecost)+1.days ... d(.EndOfYear):
            return "\(dayOfWeek) \((d(.Pentecost)+1.days) >> date) after Pentecost"
            
        default: return nil
        }
    }
    
    static func getToneDescription(date: NSDate) -> NSString? {
        func toneFromOffset(offset: Int) -> Int {
            let reminder = (offset - 1) % 8
            return (reminder == 0) ? 8 : reminder
        }
        
        let dateComponents = NSDateComponents(date: date)
        
        currentYear = dateComponents.year
        let pascha = paschaDay(currentYear)
        let prevPascha = paschaDay(currentYear-1)
        
        switch (date) {
        case d(.StartOfYear) ..< d(.PalmSunday): return "Tone \(toneFromOffset(prevPascha >> date))"
        case d(.SecondSundayAfterPascha)+1.days ... d(.EndOfYear): return "Tone \(toneFromOffset(pascha >> date))"
        default: return nil
        }
    }
    
    enum FastingType {
        case NoFast, Vegetarian, FishAllowed, FastFree, Cheesefare
    }
    
    static func getFastingDescription(date: NSDate) -> (FastingType, NSString)? {
        let dateComponents = NSDateComponents(date: date)
        
        let currentYear = dateComponents.year
        let weekday = dateComponents.weekday
        let pascha = paschaDay(currentYear)
        
        switch date {
        case d(.Theophany),
        d(.MeetingOfLord):
            return (.FastFree, "No fast")
            
        case d(.NativityOfTheotokos),
        d(.PeterAndPaul),
        d(.Dormition),
        d(.Veil):
            return (weekday == 4 || weekday == 6) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")
            
        case d(.NativityOfJohn),
        d(.Transfiguration),
        d(.EntryIntoTemple),
        d(.StNicholas):
            return (.FishAllowed, "Fish Allowed")
            
        case d(.EveOfTheophany),
        d(.BeheadingOfJohn),
        d(.ExaltationOfCross):
            return (.Vegetarian, "Vegetarian")
            
        case d(.StartOfYear):
            return (weekday == 7 || weekday == 1) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
            
        case d(.StartOfYear)+1.days ..< d(.NativityOfGod):
            return (.Vegetarian, "Nativity Fast")
            
        case d(.NativityOfGod) ..< d(.EveOfTheophany):
            return (.FastFree, "Svyatki")
            
        case d(.SundayOfPublicianAndPharisee)+1.days ... d(.SundayOfProdigalSon):
            return (.FastFree, "Fast-free week")
            
        case d(.SundayOfDreadJudgement) ... d(.ForgivenessSunday):
            return (.Cheesefare, "Maslenitsa")
            
        case d(.BeginningOfGreatLent) ... d(.PalmSunday):
            return (date == d(.Annunciation)) ? (.FishAllowed, "Fish allowed") : (.Vegetarian, "Great Lent")
            
        case d(.PalmSunday)+1.days ..< pascha:
            return (.Vegetarian, "Vegetarian")
            
        case pascha ..< d(.SecondSundayAfterPascha):
            return (.FastFree, "Fast-free week")
            
        case d(.Pentecost)+1.days ... d(.Pentecost)+7.days:
            return (.FastFree, "Fast-free week")
            
        case d(.Pentecost)+8.days ... d(.PeterAndPaul)-1.days:
            return (weekday == 2 || weekday == 4 || weekday == 6) ? (.Vegetarian, "Apostoles' Fast") : (.FishAllowed, "Apostoles' Fast")
            
        case d(.BeginningOfDormitionFast) ... d(.Dormition)-1.days:
            return (.Vegetarian, "Dormition Fast")
            
        case d(.BeginningOfNativityFast) ..< d(.StNicholas):
            return (weekday == 2 || weekday == 4 || weekday == 6) ? (.Vegetarian, "Nativity Fast") : (.FishAllowed, "Nativity Fast")
            
        case d(.StNicholas) ... d(.EndOfYear):
            return (weekday == 7 || weekday == 1) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
            
        case d(.NativityOfGod) ..< d(.Pentecost)+8.days:
            return (weekday == 4 || weekday == 6) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")
            
        default:
            return (weekday == 4 || weekday == 6) ? (.Vegetarian, "Vegetarian") : (.NoFast, "No fast")
        }
        
    }
    
    /*
    static func printFeastDescription() {
    // get Pascha day to trigger calendar initialization
    let dateComponents = NSDateComponents(date: NSDate())
    let _ = paschaDay(dateComponents.year)
    
    for (date, code) in feastDates {
    let date_str = formatter.stringFromDate(date)
    println("\(date_str) \(feastStrings[code])")
    }
    }
    */
    
}

