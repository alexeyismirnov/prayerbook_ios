// Playground - noun: a place where people can play

import UIKit

enum NameOfDay: Int {
    case StartOfYear=0, Pascha, Pentecost, Ascension, PalmSunday, NativityOfGod=5, Circumcision, EveOfTheophany, Theophany, MeetingOfLord, Annunciation=10, NativityOfJohn, PeterAndPaul, Transfiguration, Dormition, BeheadingOfJohn=15, NativityOfTheotokos, ExaltationOfCross, Veil, EntryIntoTemple, StNicholas=20, BeginningOfGreatLent, ZacchaeusSunday, SundayOfPublicianAndPharisee, SundayOfProdigalSon, SundayOfDreadJudgement=25, ForgivenessSunday, FirstSundayOfGreatLent, SecondSundayOfGreatLent, ThirdSundayOfGreatLent, FourthSundayOfGreatLent=30, FifthSundayOfGreatLent, LazarusSaturday, SecondSundayAfterPascha, ThirdSundayAfterPascha, FourthSundayAfterPascha=35, FifthSundayAfterPascha, SixthSundayAfterPascha, SeventhSundayAfterPascha, BeginningOfDormitionFast, BeginningOfNativityFast=40, BeginningOfApostolesFast, HolySpirit, EndOfYear
}

enum FastingType: Int {
    case NoFast=0, Vegetarian, FishAllowed, FastFree, Cheesefare
}

struct DateCache : Hashable {
    let code : NameOfDay
    let year : Int
    init(_ code: NameOfDay, _ year: Int) {
        self.code = code
        self.year = year
    }
    var hashValue: Int {
        return code.hashValue ^ year.hashValue
    }
}

// MARK: Equatable

func == (lhs: DateCache, rhs: DateCache) -> Bool {
    return lhs.code == rhs.code && lhs.year == rhs.year
}

struct ChurchCalendar {
    
    static var dict: NSArray = {
        let bundle = NSBundle.mainBundle().pathForResource("ChurchCalendar", ofType: "plist")
        let dict = NSArray(contentsOfFile: bundle!)
        return dict!
    }()
    
    static var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        return formatter
        }()
    
    static var currentYear : Int = 0
    static var feastDates = [NSDate: [NameOfDay]]()
    static var dCache = [ DateCache : NSDate ]()
    
    static func _d(code: NameOfDay, _ year:Int) -> NSDate {
        var res = filter(ChurchCalendar.feastDates, { (date, codes) in return contains(codes, code) && NSDateComponents(date:date).year == year } )
        dCache[DateCache(code, year)] = res[0].0
        return res[0].0
    }
    
    static func d(code: NameOfDay, _ year:Int = currentYear) -> NSDate {
        return dCache[DateCache(code, year)]!
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
    
    static let greatFeastCodes : [NameOfDay] = [.PalmSunday, .Pascha, .Ascension, .Pentecost, .NativityOfGod, .Circumcision, .Theophany, .MeetingOfLord, .Annunciation, .NativityOfJohn, .PeterAndPaul, .Transfiguration, .Dormition, .BeheadingOfJohn, .NativityOfTheotokos, .ExaltationOfCross, .Veil, .EntryIntoTemple]
    
    static func generateFeasts(year: Int) {
        let pascha = paschaDay(year)
        let greatLentStart = pascha-48.days

        let movingFeasts : [NSDate: [NameOfDay]] = [
            greatLentStart-29.days:                   [.ZacchaeusSunday],
            greatLentStart-22.days:                   [.SundayOfPublicianAndPharisee],
            greatLentStart-15.days:                   [.SundayOfProdigalSon],
            greatLentStart-8.days:                    [.SundayOfDreadJudgement],
            greatLentStart-1.days:                    [.ForgivenessSunday],
            greatLentStart:                           [.BeginningOfGreatLent],
            greatLentStart+6.days:                    [.FirstSundayOfGreatLent],
            greatLentStart+13.days:                   [.SecondSundayOfGreatLent],
            greatLentStart+20.days:                   [.ThirdSundayOfGreatLent],
            greatLentStart+27.days:                   [.FourthSundayOfGreatLent],
            greatLentStart+34.days:                   [.FifthSundayOfGreatLent],
            greatLentStart+40.days:                   [.LazarusSaturday],
            pascha-7.days:                            [.PalmSunday],
            pascha+7.days:                            [.SecondSundayAfterPascha],
            pascha+14.days:                           [.ThirdSundayAfterPascha],
            pascha+21.days:                           [.FourthSundayAfterPascha],
            pascha+28.days:                           [.FifthSundayAfterPascha],
            pascha+35.days:                           [.SixthSundayAfterPascha],
            pascha+39.days:                           [.Ascension],
            pascha+42.days:                           [.SeventhSundayAfterPascha],
            pascha+49.days:                           [.Pentecost],
            pascha+50.days:                           [.HolySpirit],
            pascha+57.days:                           [.BeginningOfApostolesFast],
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
        
        let start: Int = NameOfDay.StartOfYear.rawValue
        let end: Int = NameOfDay.EndOfYear.rawValue
        
        for index in start...end {
            let code = NameOfDay(rawValue: index)
            let date = _d(code!, year)
        }

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
                if let strings = dict[code.rawValue] as? NSDictionary {
                    if let str  = strings[Translate.language] as? String {
                        result = result + (str, contains(greatFeastCodes, code) ? UIColor.redColor() : UIColor.grayColor())
                        result = result + "\n"
                    }
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
            return  String(format: Translate.s("\(dayOfWeek) %d after Pentecost"), (d(.HolySpirit, currentYear-1) >> date)/7+1)

        case d(.SundayOfPublicianAndPharisee)+1.days ..< d(.SundayOfProdigalSon):
            return "Week of the Publican and the Pharisee"
            
        case d(.SundayOfProdigalSon)+1.days ..< d(.SundayOfDreadJudgement):
            return "Week of the Prodigal Son"
            
        case d(.SundayOfDreadJudgement)+1.days ..< d(.BeginningOfGreatLent):
            return "Week of the Dread Judgement"
            
        case d(.BeginningOfGreatLent) ..< d(.PalmSunday):
            return (dateComponents.weekday == 1) ? nil : "Week \((d(.BeginningOfGreatLent) >> date)/7+1) of Great Lent"
            
        case d(.PalmSunday)+1.days ..< pascha:
            return "Passion Week"
            
        case pascha+1.days ..< d(.SecondSundayAfterPascha):
            return "Bright Week"
            
        case d(.SecondSundayAfterPascha)+1.days ..< d(.Pentecost):
            return (dateComponents.weekday == 1) ? nil : "Week \((pascha >> date)/7+1) after Pascha"

        case d(.HolySpirit) ..< d(.Pentecost)+7.days:
            return "Trinity Week"
            
        case d(.Pentecost)+7.days ... d(.EndOfYear):
            return  String(format: Translate.s("\(dayOfWeek) %d after Pentecost"), (d(.HolySpirit) >> date)/7+1)
            
        default: return nil
        }
    }
    
    static func getToneDescription(date: NSDate) -> NSString? {
        func tone(#dayNum: Int) -> Int {
            let reminder = (dayNum/7) % 8
            return (reminder == 0) ? 8 : reminder
        }
        
        var formatter = NSNumberFormatter()
        formatter.locale = Translate.locale
        
        if Translate.language == "cn" {
            formatter.numberStyle = .SpellOutStyle
        }
        
        let dateComponents = NSDateComponents(date: date)
        currentYear = dateComponents.year
        let pascha = paschaDay(currentYear)
        let prevPascha = paschaDay(currentYear-1)
        
        switch (date) {
        case d(.StartOfYear) ..< d(.PalmSunday):
            return String(format: Translate.s("Tone %@"), formatter.stringFromNumber(tone(dayNum: prevPascha >> date))!)

        case d(.SecondSundayAfterPascha)+1.days ... d(.EndOfYear):
            return String(format: Translate.s("Tone %@"), formatter.stringFromNumber(tone(dayNum: pascha >> date))!)

        default: return nil
        }
    }

    static func getFastingDescription(date: NSDate) -> (FastingType, String)? {
        let dateComponents = NSDateComponents(date: date)
        
        currentYear = dateComponents.year
        let weekday = dateComponents.weekday
        let pascha = paschaDay(currentYear)
        
        switch date {
        case d(.Theophany),
        d(.MeetingOfLord):
            return (.NoFast, "No fast")
            
        case d(.NativityOfTheotokos),
        d(.PeterAndPaul),
        d(.Dormition),
        d(.Veil):
            return (weekday == 4 || weekday == 6) ? (.FishAllowed, "Fish Allowed") : (.NoFast, "No fast")
            
        case d(.NativityOfJohn),
        d(.Transfiguration),
        d(.EntryIntoTemple),
        d(.StNicholas),
        d(.PalmSunday):
            return (.FishAllowed, "Fish Allowed")
            
        case d(.EveOfTheophany),
        d(.BeheadingOfJohn),
        d(.ExaltationOfCross):
            return (.Vegetarian, "Fast day")
            
        case d(.StartOfYear):
            return (weekday == 7 || weekday == 1) ? (.FishAllowed, "Nativity Fast") : (.Vegetarian, "Nativity Fast")
            
        case d(.StartOfYear)+1.days ..< d(.NativityOfGod):
            return (.Vegetarian, "Nativity Fast")
            
        case d(.NativityOfGod) ..< d(.EveOfTheophany):
            return (.FastFree, "Svyatki")
            
        case d(.SundayOfPublicianAndPharisee)+1.days ... d(.SundayOfProdigalSon):
            return (.FastFree, "Fast-free week")
            
        case d(.SundayOfDreadJudgement)+1.days ... d(.ForgivenessSunday):
            return (.Cheesefare, "Maslenitsa")
            
        case d(.BeginningOfGreatLent) ..< d(.PalmSunday):
            return (date == d(.Annunciation)) ? (.FishAllowed, "Fish allowed") : (.Vegetarian, "Great Lent")
            
        case d(.PalmSunday)+1.days ..< pascha:
            return (.Vegetarian, "Vegetarian")
            
        case pascha+1.days ... d(.SecondSundayAfterPascha):
            return (.FastFree, "Fast-free week")
            
        case d(.Pentecost)+1.days ... d(.Pentecost)+7.days:
            return (.FastFree, "Fast-free week")
            
        case d(.BeginningOfApostolesFast) ... d(.PeterAndPaul)-1.days:
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

}

