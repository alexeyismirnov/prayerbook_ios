//
//  ChurchCalendar2.swift
//  ponomar
//
//  Created by Alexey Smirnov on 1/13/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation

public class ChurchCalendar {
    public var year: Int
    var days = [ChurchDay]()
    
    public var startOfYear, endOfYear : Date
    public var greatLentStart, pascha, pentecost : Date
    
    static var calendars = [Int:ChurchCalendar]()
    
    static public func fromDate(_ date: Date) -> ChurchCalendar {
        let year = DateComponents(date: date).year!
        
        if calendars[year] == nil {
            calendars[year] = ChurchCalendar(date)
        }
        
        return calendars[year]!
    }
    
    init(_ date: Date) {
        let dateComponents = DateComponents(date: date)
        year = dateComponents.year!
        
        startOfYear = Date(1, 1, year)
        endOfYear = Date(31, 12, year)
        
        pascha = Cal.paschaDay(year)
        greatLentStart = pascha-48.days
        pentecost = pascha+49.days
        
        initDays()
        initGreatLent()
        initSatSun()
        initMisc()
        initBeforeAfterFeasts()
    }
    
    func initDays() {
        /*
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        
        let jsonData = try! encoder.encode(days)
        let jsonString = String(data: jsonData, encoding: .utf8)
        
        print("JSON String : " + jsonString!)
         */
        
        let url = Bundle.module.url(forResource: "calendar", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let decoder = JSONDecoder()
        decoder.userInfo = [.year: year]
        days = try! decoder.decode([ChurchDay].self, from: data)
        
        // print(days)
    }
    
    func initGreatLent() {
        // TRIODION
        day("sundayOfZacchaeus").date = greatLentStart-29.days
        day("sundayOfPublicianAndPharisee").date = greatLentStart-22.days
        day("sundayOfProdigalSon").date = greatLentStart-15.days
        day("saturdayOfDeparted").date = greatLentStart-9.days
        day("sundayOfDreadJudgement").date = greatLentStart-8.days
        day("saturdayOfFathers").date = greatLentStart-2.days
        day("cheesefareSunday").date = greatLentStart-1.days
        
        // GREAT LENT
        day("beginningOfGreatLent").date = greatLentStart
        day("saturday1GreatLent").date = greatLentStart+5.days
        day("sunday1GreatLent").date = greatLentStart+6.days
        day("saturday2GreatLent").date = greatLentStart+12.days
        day("sunday2GreatLent").date = greatLentStart+13.days
        day("saturday3GreatLent").date = greatLentStart+19.days
        day("sunday3GreatLent").date = greatLentStart+20.days
        day("saturday4GreatLent").date = greatLentStart+26.days
        day("sunday4GreatLent").date = greatLentStart+27.days
        day("thursday5GreatLent").date = greatLentStart+31.days
        day("saturday5GreatLent").date = greatLentStart+33.days
        day("sunday5GreatLent").date = greatLentStart+34.days
        
        day("lazarusSaturday").date = pascha-8.days
        day("palmSunday").date = pascha-7.days
        days.append(ChurchDay("greatMonday", .none, date: pascha-6.days))
        days.append(ChurchDay("greatTuesday", .none, date: pascha-5.days))
        days.append(ChurchDay("greatWednesday", .none, date: pascha-4.days))
        days.append(ChurchDay("greatThursday", .none, date: pascha-3.days))
        days.append(ChurchDay("greatFriday", .none, date: pascha-2.days))
        days.append(ChurchDay("greatSaturday", .none, date: pascha-1.days))
        
        // PASCHA
        day("pascha").date = pascha
        day("sunday2AfterPascha").date = pascha+7.days
        day("radonitsa").date = pascha+9.days
        day("sunday3AfterPascha").date = pascha+14.days
        day("sunday4AfterPascha").date = pascha+21.days
        days.append(ChurchDay("midPentecost", .none, date: pascha+24.days))
        day("sunday5AfterPascha").date = pascha+28.days
        day("sunday6AfterPascha").date = pascha+35.days
        day("ascension").date = pascha+39.days
        day("sunday7AfterPascha").date = pascha+42.days
        day("saturdayTrinity").date = pascha+48.days
        
        // PENTECOST
        day("pentecost").date = pascha+49.days
        days.append(ChurchDay("holySpirit", .none, date: pentecost+1.days))
        day("beginningOfApostlesFast").date = pentecost+8.days
        day("sunday1AfterPentecost").date = pentecost+7.days
        day("sunday2AfterPentecost").date = pentecost+14.days
    }
    
    func initSatSun() {
        func saturdayBeforeNativity(_ date: Date) -> ChurchDay {
            ChurchDay("saturdayBeforeNativity", .none, date: date, reading: "Gal 3:8-12 Luke 13:18-29 # Saturday before the Nativity")
        }
        
        func sundayBeforeNativity(_ date: Date) -> ChurchDay {
            ChurchDay("sundayBeforeNativity", .none, date: date, reading: "Heb 11:9-10,17-23,32-40 Matthew 1:1-25 # Sunday before the Nativity")
        }
        
        // EXALTATION SAT & SUN
        let exaltation = Date(27, 9, year)
        let exaltationWeekday = DateComponents(date: exaltation).weekday!
        let exaltationSatOffset = (exaltationWeekday == 7) ? 7 : 7-exaltationWeekday
        let exaltationSunOffset = (exaltationWeekday == 1) ? 7 : exaltationWeekday-1

        day("sundayAfterExaltation").date = exaltation + (8-exaltationWeekday).days
        day("saturdayAfterExaltation").date = exaltation + exaltationSatOffset.days
        day("sundayBeforeExaltation").date = exaltation - exaltationSunOffset.days
        day("saturdayBeforeExaltation").date = exaltation - exaltationWeekday.days
       
        // NATIVITY SAT & SUN
        let nativity = Date(7, 1, year)
        let nativityWeekday = DateComponents(date:nativity).weekday!
        let nativitySunOffset = (nativityWeekday == 1) ? 7 : (nativityWeekday-1)
        let nativitySatOffset = (nativityWeekday == 7) ? 7 : 7-nativityWeekday
        
        if nativitySunOffset != 7 {
            days.append(sundayBeforeNativity(nativity - nativitySunOffset.days))
        }

        if nativityWeekday != 7 {
            days.append(saturdayBeforeNativity(nativity - nativityWeekday.days))
        }

        day("sundayAfterNativity").date = nativity + (8-nativityWeekday).days
        day("saturdayAfterNativity").date = nativity + nativitySatOffset.days

        if nativityWeekday == 1 {
            day("josephBetrothed").date = nativity + 1.days

        } else {
            day("josephBetrothed").date = nativity + (8-nativityWeekday).days
        }
        
        let nativityNextYear = Date(7, 1, year+1)
        let nativityNextYearWeekday = DateComponents(date:nativityNextYear).weekday!
        var nativityNextYearSunOffset = (nativityNextYearWeekday == 1) ? 7 : (nativityNextYearWeekday-1)

        if nativityNextYearSunOffset == 7 {
            days.append(sundayBeforeNativity(Date(31, 12, year)))
        }
        
        if nativityNextYearWeekday == 7 {
            days.append(saturdayBeforeNativity(Date(31, 12, year)))
        }
        
        nativityNextYearSunOffset += 7
        day("sundayOfForefathers").date = nativityNextYear - nativityNextYearSunOffset.days
        
        // THEOPHANY SAT & SUN
        let theophany = Date(19, 1, year)
        let theophanyWeekday = DateComponents(date:theophany).weekday!

        let theophanySunOffset = (theophanyWeekday == 1) ?  7 : (theophanyWeekday-1)
        let theophanySatOffset = (theophanyWeekday == 7) ? 7 : 7-theophanyWeekday
        
        day("sundayBeforeTheophany").date = theophany - theophanySunOffset.days
        day("saturdayBeforeTheophany").date = theophany - theophanyWeekday.days
        day("sundayAfterTheophany").date = theophany + (8-theophanyWeekday).days
        day("saturdayAfterTheophany").date = theophany + theophanySatOffset.days
        
        // DEMETRIUS SAT
        let demetrius = Date(8, 11, year)
        var demetriusSat = ChurchCalendar.nearestSaturdayBefore(demetrius)
        
        if demetriusSat == Date(4, 11, year) {
            demetriusSat = demetriusSat + 7.days
        }
        
        day("demetriusSaturday").date =  demetriusSat
    }
    
    func initMisc() {
        day("newMartyrsConfessorsOfRussia").date = ChurchCalendar.nearestSunday(Date(7,2,year))
        day("holyFathersSixCouncils").date = ChurchCalendar.nearestSunday(Date(29, 7, year))
        day("holyFathersSeventhCouncil").date = ChurchCalendar.nearestSunday(Date(24, 10, year))
        day("findingOfHead").date = isLeapYear ? Date(8, 3, year) : Date(9, 3, year)
        
        // SYNAXIS
        days.append(ChurchDay("synaxisKievCavesSaints", .none, date: greatLentStart+13.days))
        days.append(ChurchDay("synaxisMartyrsButovo", .none, date: pascha+27.days))
        days.append(ChurchDay("synaxisMountAthosSaints", .none, date: pentecost+14.days))
        
        if Translate.language == "ru" {
            days.append(ChurchDay("synaxisMoscowSaints", .none, date: ChurchCalendar.nearestSundayBefore(Date(8, 9, year))))
            days.append(ChurchDay("synaxisNizhnyNovgorodSaints", .none, date: ChurchCalendar.nearestSundayAfter(Date(7, 9, year))))
            days.append(ChurchDay("synaxisPskovCavesSaints", .none, date: pentecost+28.days))
        }
        
        let synaxisTheotokos = Date(8, 1, year)
        let synaxisTheotokosW = DayOfWeek(rawValue: synaxisTheotokos.weekday)
        
        if synaxisTheotokosW == .monday {
            days.append(ChurchDay("", .doxology, date: synaxisTheotokos, reading: "Heb 2:11-18 # Theotokos"))
            days.append(ChurchDay("", .doxology, date: synaxisTheotokos, reading: "Gal 1:11-19 Matthew 2:13-23 # Holy Ancestors"))
            
        } else if synaxisTheotokosW != .sunday {
            days.append(ChurchDay("", .doxology, date: synaxisTheotokos, reading: "Heb 2:11-18 Matthew 2:13-23 # Theotokos"))
        }
        
        days.append(ChurchDay("josephArimathea", .noSign, date: pascha+14.days))
        days.append(ChurchDay("tamaraGeorgia", .noSign, date: pascha+14.days))
        days.append(ChurchDay("abrahamBulgar", .noSign, date: pascha+21.days))
        days.append(ChurchDay("tabithaJoppa", .noSign, date: pascha+21.days))
        
        // ICONS OF THEOTOKOS
        days.append(ChurchDay("iveronTheotokos", .none, date: pascha+2.days))
        days.append(ChurchDay("springTheotokos", .none, date: pascha+5.days))
        days.append(ChurchDay("mozdokTheotokos", .none, date: pascha+24.days))
        days.append(ChurchDay("chelnskoyTheotokos", .none, date: pascha+42.days))
        days.append(ChurchDay("tupichevskTheotokos", .none, date: pentecost+1.days))
        days.append(ChurchDay("koretsTheotokos", .none, date: pentecost+4.days))
        days.append(ChurchDay("softenerTheotokos", .none, date: pentecost+7.days))
        days.append(ChurchDay("kurskTheotokos", .none, date: pentecost+12.days))
    }
    
    func generateBeforeAfter(feast: String,
                             daysBefore: Int = 0, signBefore: FeastType = .noSign,
                             daysAfter: Int = 0, signAfter: FeastType = .noSign,
                             signApodosis: FeastType = .doxology) {
        
        let date = d(feast)
        let eve1 = d("eveOfNativityOfGod")
        let eve2 = d("eveOfTheophany")

        if daysBefore > 0 {
            for forefeast in DateRange(date-daysBefore.days, date-1.days) {
                if forefeast != eve1 && forefeast != eve2 {
                    days.append(ChurchDay("forefeast_\(feast)", signBefore, date: forefeast))
                }
            }
        }
        
        if daysAfter > 0 {
            for afterfeast in DateRange(date+1.days, date+daysAfter.days) {
                days.append(ChurchDay("afterfeast_\(feast)", signAfter, date: afterfeast))
            }
        }
        
        days.append(ChurchDay("apodosis_\(feast)", signApodosis, date: date+(daysAfter+1).days))

    }
    
    func initBeforeAfterFeasts() {
        days.append(ChurchDay("apodosis_pascha", .none, date: pascha+38.days))
        
        generateBeforeAfter(feast: "ascension",
                            daysAfter: 7, signAfter: .none,
                            signApodosis: .none)
        
        generateBeforeAfter(feast: "pentecost",
                            daysAfter: 5, signAfter: .none,
                            signApodosis: .none)
                
        generateBeforeAfter(feast: "nativityOfGod", daysBefore: 5, daysAfter: 5)
        generateBeforeAfter(feast: "theophany", daysBefore: 4, daysAfter: 7, signApodosis: .noSign)
        generateBeforeAfter(feast: "transfiguration", daysBefore: 1, signBefore: .sixVerse, daysAfter: 6)
        generateBeforeAfter(feast: "dormition", daysBefore: 1, signBefore: .sixVerse, daysAfter: 7)
        generateBeforeAfter(feast: "nativityOfTheotokos", daysBefore: 1, signBefore: .sixVerse, daysAfter: 3)
        generateBeforeAfter(feast: "exaltationOfCross", daysBefore: 1, daysAfter: 6)
        generateBeforeAfter(feast: "entryIntoTemple", daysBefore: 1, daysAfter: 3)

        let annunciation = d("annunciation")
        
        switch annunciation {
        case greatLentStart ..< d("lazarusSaturday"):
            days.append(ChurchDay("forefeast_annunciation", .sixVerse, date: annunciation-1.days))
            days.append(ChurchDay("apodosis_annunciation", .doxology, date: annunciation+1.days))

        case d("lazarusSaturday"):
            days.append(ChurchDay("forefeast_annunciation", .sixVerse, date: annunciation-1.days))

        default:
            break
        }
        
        let meetingOfLord = d("meetingOfLord")
        days.append(ChurchDay("forefeast_meetingOfLord", .sixVerse, date: meetingOfLord-1.days))

        var lastDay = meetingOfLord
        
        switch (meetingOfLord) {
        case startOfYear ..< d("sundayOfProdigalSon")-1.days:
            lastDay = meetingOfLord+7.days

        case d("sundayOfProdigalSon")-1.days ... d("sundayOfProdigalSon")+2.days:
            lastDay = d("sundayOfProdigalSon")+5.days

        case d("sundayOfProdigalSon")+3.days ..< d("sundayOfDreadJudgement"):
            lastDay = d("sundayOfDreadJudgement") + 2.days
            
        case d("sundayOfDreadJudgement") ... d("sundayOfDreadJudgement")+1.days:
            lastDay = d("sundayOfDreadJudgement") + 4.days

        case d("sundayOfDreadJudgement")+2.days ... d("sundayOfDreadJudgement")+3.days:
            lastDay = d("sundayOfDreadJudgement") + 6.days

        case d("sundayOfDreadJudgement")+4.days ... d("sundayOfDreadJudgement")+6.days:
            lastDay = d("cheesefareSunday")

        default:
            break
        }
        
        if (lastDay != meetingOfLord) {
            for afterfeastDay in DateRange(meetingOfLord+1.days, lastDay-1.days) {
                days.append(ChurchDay("afterfeast_meetingOfLord", .noSign, date: afterfeastDay))
            }
            days.append(ChurchDay("apodosis_meetingOfLord", .doxology, date: lastDay))
        }

    }
    
    public func d(_ name: String) -> Date {
        // there can be zero Sundays before Nativity in a given year
        if name == "sundayBeforeNativity1" {
            let results = days.filter({ $0._name == "sundayBeforeNativity" })
            return results.first?.date! ?? Date(1, 1, 1980)
            
        } else if name == "sundayBeforeNativity2" {
            let results = days.filter({ $0._name == "sundayBeforeNativity" })
            return results.last?.date! ?? Date(1, 1, 1980)

        } else {
            return day(name).date!
        }
        
    }
    
    public func day(_ name: String) -> ChurchDay {
        days.filter() { $0._name == name }.first!
    }
    
}

public extension ChurchCalendar {
    var isLeapYear: Bool {
        get { (year % 400) == 0 || ((year % 4 == 0) && (year % 100 != 0)) }
    }
    
    var leapStart: Date {
        get { Date(29, 2, year) }
    }
    
    var leapEnd: Date {
        get { Date(13, 3, year) }
    }
}

public extension ChurchCalendar {    
    static func paschaDay(_ year: Int) -> Date {
        // http://calendar.lenacom.spb.ru/index.php
        let a = (19*(year%19) + 15) % 30
        let b = (2*(year%4) + 4*(year%7) + 6*a + 6) % 7

        return  ((a+b > 10) ? Date(a+b-9, 4, year) : Date(22+a+b, 3, year)) + 13.days
    }
    
    static func isLeap(year: Int) -> Bool {
        (year % 400) == 0 || ((year % 4 == 0) && (year % 100 != 0))
    }
    
    // 1 is Sunday
    static func nearestSundayAfter(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let offset = (weekday == 1) ? 7 : 8-weekday
        return date + offset.days
    }
    
    static func nearestSaturdayAfter(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let offset = (weekday == 7) ? 7 : 7-weekday
        return date + offset.days
    }

    static func nearestSundayBefore(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let offset = (weekday == 1) ? 7 : weekday-1
        return date - offset.days
    }
    
    static func nearestSaturdayBefore(_ date: Date) -> Date {
        let weekday = DateComponents(date:date).weekday!
        let offset = (weekday == 7) ? 7 : weekday
        return date - offset.days
    }
    
    static func getGreatFeast(_ date: Date) -> [ChurchDay]  {
        Cal.fromDate(date).days.filter({ $0.date == date && $0.type == .great})
    }
    
    static func nearestSunday(_ date: Date) -> Date {
        let weekday = DayOfWeek(rawValue: DateComponents(date:date).weekday!)!
        
        switch (weekday) {
        case .sunday:
            return date
            
        case .monday, .tuesday, .wednesday:
            return ChurchCalendar.nearestSundayBefore(date)
            
        default:
            return ChurchCalendar.nearestSundayAfter(date)
        }
    }
    
    public func getDayDescription(_ date: Date) -> [ChurchDay] {
        days
            .filter({ $0.date == date && $0._name.count > 0 })
            .sorted { $0.type.rawValue < $1.type.rawValue }
    }
    
    func getDayReadings(_ date: Date) -> [ChurchDay] {
        days
            .filter({ $0.date == date && $0.reading != nil })
            .sorted { $0.type.rawValue > $1.type.rawValue }
    }
    
    func getAllReadings() -> [ChurchDay] {
        days.filter({ $0.reading != nil })
    }
    
    public func getWeekDescription(_ date: Date) -> String? {
        let weekday = DayOfWeek(date: date)!
        let dayOfWeek = (weekday == .sunday) ? "Sunday" : "Week"
    
        switch (date) {
        case startOfYear ..< d("sundayOfPublicianAndPharisee"):
            return  String(format: Translate.s("\(dayOfWeek)AfterPentecost"),
                           Translate.stringFromNumber(((Cal.paschaDay(year-1)+50.days) >> date)/7+1))
            
        case d("sundayOfPublicianAndPharisee")+1.days ..< d("sundayOfProdigalSon"):
            return Translate.s("weekOfPublicianAndPharisee")

        case d("sundayOfProdigalSon")+1.days ..< d("sundayOfDreadJudgement"):
            return Translate.s("weekOfProdigalSon")

        case d("sundayOfDreadJudgement")+1.days ..< d("cheesefareSunday"):
            return Translate.s("weekOfDreadJudgement")

        case d("beginningOfGreatLent") ..< d("palmSunday"):
            return  String(format: Translate.s("\(dayOfWeek)OfGreatLent"),
                           Translate.stringFromNumber((d("beginningOfGreatLent") >> date)/7+1))
        
        case d("palmSunday")+1.days ..< pascha:
            return Translate.s("holyWeek")
            
        case pascha+1.days ..< pascha+7.days:
            return Translate.s("brightWeek")
            
        case pascha+8.days ..< pentecost:
            let weekNum = (pascha >> date)/7+1
            return (weekday == .sunday) ? nil : String(format: Translate.s("WeekAfterPascha"),
                                                       Translate.stringFromNumber(weekNum))
            
        case pentecost+1.days ... endOfYear:
            return  String(format: Translate.s("\(dayOfWeek)AfterPentecost"),
                           Translate.stringFromNumber(((pentecost+1.days) >> date)/7+1))
            
        default: return nil
        }
    }
    
    func getTone(_ date: Date) -> Int? {
        func tone(dayNum: Int) -> Int {
            let reminder = (dayNum/7) % 8
            return (reminder == 0) ? 8 : reminder
        }
                
        switch (date) {
        case startOfYear ..< d("palmSunday"):
            return tone(dayNum: Cal.paschaDay(year-1) >> date)
            
        case pascha+8.days ... endOfYear:
            return tone(dayNum: pascha >> date)
            
        default: return nil
        }
    }
    
    public func getToneDescription(_ date: Date) -> String? {
        if let tone = getTone(date) {
            return String(format: Translate.s("tone"), Translate.stringFromNumber(tone))

        } else {
            return nil
        }
    }
}

public typealias Cal = ChurchCalendar
public typealias Saint = ChurchDay
