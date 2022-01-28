//
//  ChurchFasting.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 1/27/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

public class ChurchFasting {
    var cal: Cal2
    var stNicholas: Date
    
    static var models = [Int:ChurchFasting]()
    
    init(_ date: Date) {
        cal = Cal2.fromDate(date)
        stNicholas = Date(19, 12, cal.year)
    }

    static public func forDate(_ date: Date) -> FastingModel {
        let dateComponents = DateComponents(date: date)
        let year = dateComponents.year!
        
        if models[year] == nil {
            models[year] = ChurchFasting(date)
        }
        
        switch FastingModel.fastingLevel! {
        case .laymen:
            return models[year]!.getFastingLaymen(date)
            
        case .monastic:
            return models[year]!.getFastingMonastic(date)
        }
        
    }
    
    func getFastingLaymen(_ date: Date) -> FastingModel {
        let weekday = DayOfWeek(date: date)!

        switch date {
        case cal.d("meetingOfLord"):
            return meetingOfLord(date, weekday, monastic: false)
            
        case cal.d("theophany"):
            return FastingModel(.noFast)
            
        case cal.d("nativityOfTheotokos"),
             cal.d("peterAndPaul"),
             cal.d("dormition"),
             cal.d("veilOfTheotokos"):
            return (weekday == .wednesday || weekday == .friday)
                ? FastingModel(.fishAllowed)
                : FastingModel(.noFast)
            
        case cal.d("nativityOfJohn"),
             cal.d("transfiguration"),
             cal.d("entryIntoTemple"),
             stNicholas,
             cal.d("palmSunday"):
            return FastingModel(.fishAllowed)
            
        case cal.d("eveOfTheophany"),
             cal.d("beheadingOfJohn"),
             cal.d("exaltationOfCross"):
            return FastingModel(.vegetarian, "fast_day")
            
        case cal.startOfYear:
            return (weekday == .saturday || weekday == .sunday)
                ? FastingModel(.fishAllowed, "nativity_fast")
                : FastingModel(.vegetarian, "nativity_fast")
            
        case cal.startOfYear+1.days ..< cal.d("nativityOfGod"):
            return FastingModel(.vegetarian, "nativity_fast")
            
        case cal.d("nativityOfGod") ..< cal.d("eveOfTheophany"):
            return FastingModel(.fastFree, "svyatki")
            
        case cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon"):
            return FastingModel(.fastFree)
            
        case cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent"):
            return FastingModel(.cheesefare)
            
        case cal.d("beginningOfGreatLent") ..< cal.d("palmSunday"):
            return (date == cal.d("annunciation")) ? FastingModel(.fishAllowed) : FastingModel(.vegetarian, "great_lent")
            
        case cal.d("palmSunday")+1.days ..< cal.pascha:
            return FastingModel(.vegetarian)
            
        case cal.pascha+1.days ... cal.pascha+7.days:
            return FastingModel(.fastFree)
            
        case cal.pentecost+1.days ... cal.pentecost+7.days:
            return FastingModel(.fastFree)
            
        case cal.d("beginningOfApostlesFast") ... cal.d("peterAndPaul")-1.days:
            return (weekday == .monday ||
                weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.vegetarian, "apostles_fast") : FastingModel(.fishAllowed, "apostles_fast")
            
        case cal.d("beginningOfDormitionFast") ... cal.d("dormition")-1.days:
            return FastingModel(.vegetarian, "dormition_fast")
            
        case cal.d("beginningOfNativityFast") ..< stNicholas:
            return (weekday == .monday ||
                weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.vegetarian, "nativity_fast") : FastingModel(.fishAllowed, "nativity_fast")
            
        case stNicholas ... cal.endOfYear:
            return (weekday == .saturday ||
                weekday == .sunday) ? FastingModel(.fishAllowed, "nativity_fast") : FastingModel(.vegetarian, "nativity_fast")
            
        case cal.d("nativityOfGod") ..< cal.pentecost+8.days:
            return (weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFast)
            
        default:
            return (weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.vegetarian) : FastingModel(.noFast)
        }
    }
    
    func getFastingMonastic(_ date: Date) -> FastingModel {
        let weekday = DayOfWeek(date: date)!

        switch date {
        case cal.d("meetingOfLord"):
            return meetingOfLord(date, weekday, monastic: true)
            
        case cal.d("theophany"):
            return FastingModel(.noFastMonastic)
            
        case cal.d("nativityOfTheotokos"),
             cal.d("peterAndPaul"),
             cal.d("dormition"),
             cal.d("veilOfTheotokos"):
            return (weekday == .monday ||
                weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFastMonastic)
            
        case cal.d("nativityOfJohn"),
             cal.d("transfiguration"),
             cal.d("entryIntoTemple"),
             stNicholas,
             cal.d("palmSunday"):
            return FastingModel(.fishAllowed)
            
        case cal.d("eveOfTheophany"):
            return FastingModel(.xerophagy, "fast_day")
            
        case cal.d("beheadingOfJohn"),
             cal.d("exaltationOfCross"):
            return FastingModel(.withOil, "fast_day")
            
        case cal.startOfYear:
            return (weekday == .tuesday || weekday == .thursday) ?
                FastingModel(.withOil) : monasticApostolesFast(weekday)
            
        case cal.startOfYear+1.days ..< cal.d("nativityOfGod"):
            return monasticGreatLent(weekday)
            
        case cal.d("nativityOfGod") ..< cal.d("eveOfTheophany"):
            return FastingModel(.fastFree, "svyatki")
            
        case cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon"):
            return FastingModel(.fastFree)
            
        case cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent"):
            return FastingModel(.cheesefare)
            
        case cal.d("beginningOfGreatLent"):
            return FastingModel(.noFood)
            
        case cal.d("beginningOfGreatLent")+1.days ... cal.d("beginningOfGreatLent")+4.days:
            return FastingModel(.xerophagy)
            
        case cal.d("beginningOfGreatLent")+5.days ..< cal.d("palmSunday"):
            return (date == cal.d("annunciation")) ? FastingModel(.fishAllowed) : monasticGreatLent(weekday)
            
        case cal.d("palmSunday")+1.days ... cal.d("palmSunday")+4.days:
            return FastingModel(.xerophagy)
            
        case cal.d("palmSunday")+5.days:
            return FastingModel(.noFood)
            
        case cal.d("palmSunday")+6.days:
            return FastingModel(.withOil)
            
        case cal.pascha+1.days ... cal.pascha+7.days:
            return FastingModel(.fastFree)
            
        case cal.pentecost+1.days ... cal.pentecost+7.days:
            return FastingModel(.fastFree)
            
        case cal.d("beginningOfApostlesFast") ... cal.d("peterAndPaul")-1.days:
            return monasticApostolesFast(weekday)
            
        case cal.d("beginningOfDormitionFast") ... cal.d("dormition")-1.days:
            return monasticGreatLent(weekday)
            
        case cal.d("beginningOfNativityFast") ..< stNicholas:
            return monasticApostolesFast(weekday)
            
        case stNicholas ... cal.endOfYear:
            return (weekday == .tuesday || weekday == .thursday)
                ? FastingModel(.withOil)
                : monasticApostolesFast(weekday)
            
        default:
            if (weekday == .monday || weekday == .wednesday || weekday == .friday) {
                let saints = SaintModel.saints(date)
                let maxSaint = saints.max { $0.0.rawValue < $1.0.rawValue }!
                
                switch maxSaint.0 {
                case .vigil:
                    return FastingModel(.fishAllowed)
                    
                case .doxology, .polyeleos:
                    return FastingModel(.withOil)
                    
                default:
                    return FastingModel(.xerophagy)
                }
                
            } else {
                return FastingModel(.noFastMonastic)
            }
        }
    }
    
    func meetingOfLord(_ date: Date, _ weekday: DayOfWeek, monastic: Bool) -> FastingModel {
        if cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon") ~= date {
            return FastingModel(.fastFree)
            
        } else if cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent") ~= date {
            return FastingModel(.cheesefare)
            
        } else if date == cal.d("beginningOfGreatLent") {
            return monastic ? FastingModel(.noFood) : FastingModel(.vegetarian, "great_lent")
            
        } else {
            return (weekday == .monday ||
                weekday == .wednesday ||
                weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(monastic ? .noFastMonastic : .noFast)
        }
    }
    
    func monasticGreatLent(_ weekday: DayOfWeek) -> FastingModel {
        switch weekday {
        case .monday, .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday:
            return FastingModel(.withoutOil)
            
        case .saturday, .sunday:
            return FastingModel(.withOil)
        }
    }
    
    func monasticApostolesFast(_ weekday: DayOfWeek) -> FastingModel {
        switch weekday {
        case .monday:
            return FastingModel(.withoutOil)
            
        case .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday, .saturday, .sunday:
            return FastingModel(.fishAllowed)
            
        }
    }
}


