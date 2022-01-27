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
        switch date {
        case cal.d("meetingOfLord"):
            return meetingOfLord(date, monastic: false)
            
        case cal.d("theophany"):
            return FastingModel(.noFast)
            
        case cal.d("nativityOfTheotokos"),
             cal.d("peterAndPaul"),
             cal.d("dormition"),
             cal.d("veilOfTheotokos"):
            return (cal.weekday == .wednesday || cal.weekday == .friday)
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
            return FastingModel(.vegetarian, "Fast day")
            
        case cal.startOfYear:
            return (cal.weekday == .saturday || cal.weekday == .sunday)
                ? FastingModel(.fishAllowed, "Nativity Fast")
                : FastingModel(.vegetarian, "Nativity Fast")
            
        case cal.startOfYear+1.days ..< cal.d("nativityOfGod"):
            return FastingModel(.vegetarian, "Nativity Fast")
            
        case cal.d("nativityOfGod") ..< cal.d("eveOfTheophany"):
            return FastingModel(.fastFree, "Svyatki")
            
        case cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon"):
            return FastingModel(.fastFree)
            
        case cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent"):
            return FastingModel(.cheesefare)
            
        case cal.d("beginningOfGreatLent") ..< cal.d("palmSunday"):
            return (date == cal.d("annunciation")) ? FastingModel(.fishAllowed) : FastingModel(.vegetarian, "Great Lent")
            
        case cal.d("palmSunday")+1.days ..< cal.pascha:
            return FastingModel(.vegetarian)
            
        case cal.pascha+1.days ... cal.pascha+7.days:
            return FastingModel(.fastFree)
            
        case cal.pentecost+1.days ... cal.pentecost+7.days:
            return FastingModel(.fastFree)
            
        case cal.d("beginningOfApostlesFast") ... cal.d("peterAndPaul")-1.days:
            return (cal.weekday == .monday ||
                cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.vegetarian, "Apostoles' Fast") : FastingModel(.fishAllowed, "Apostoles' Fast")
            
        case cal.d("beginningOfDormitionFast") ... cal.d("dormition")-1.days:
            return FastingModel(.vegetarian, "Dormition Fast")
            
        case cal.d("beginningOfNativityFast") ..< stNicholas:
            return (cal.weekday == .monday ||
                cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.vegetarian, "Nativity Fast") : FastingModel(.fishAllowed, "Nativity Fast")
            
        case stNicholas ... cal.endOfYear:
            return (cal.weekday == .saturday ||
                cal.weekday == .sunday) ? FastingModel(.fishAllowed, "Nativity Fast") : FastingModel(.vegetarian, "Nativity Fast")
            
        case cal.d("nativityOfGod") ..< cal.pentecost+8.days:
            return (cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFast)
            
        default:
            return (cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.vegetarian) : FastingModel(.noFast)
        }
    }
    
    func getFastingMonastic(_ date: Date) -> FastingModel {
        switch date {
        case cal.d("meetingOfLord"):
            return meetingOfLord(date, monastic: true)
            
        case cal.d("theophany"):
            return FastingModel(.noFastMonastic)
            
        case cal.d("nativityOfTheotokos"),
             cal.d("peterAndPaul"),
             cal.d("dormition"),
             cal.d("veilOfTheotokos"):
            return (cal.weekday == .monday ||
                cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFastMonastic)
            
        case cal.d("nativityOfJohn"),
             cal.d("transfiguration"),
             cal.d("entryIntoTemple"),
             stNicholas,
             cal.d("palmSunday"):
            return FastingModel(.fishAllowed)
            
        case cal.d("eveOfTheophany"):
            return FastingModel(.xerophagy, "Fast day")
            
        case cal.d("beheadingOfJohn"),
             cal.d("exaltationOfCross"):
            return FastingModel(.withOil, "Fast day")
            
        case cal.startOfYear:
            return (cal.weekday == .tuesday || cal.weekday == .thursday) ?
                FastingModel(.withOil) : monasticApostolesFast()
            
        case cal.startOfYear+1.days ..< cal.d("nativityOfGod"):
            return monasticGreatLent()
            
        case cal.d("nativityOfGod") ..< cal.d("eveOfTheophany"):
            return FastingModel(.fastFree, "Svyatki")
            
        case cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon"):
            return FastingModel(.fastFree)
            
        case cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent"):
            return FastingModel(.cheesefare)
            
        case cal.d("beginningOfGreatLent"):
            return FastingModel(.noFood)
            
        case cal.d("beginningOfGreatLent")+1.days ... cal.d("beginningOfGreatLent")+4.days:
            return FastingModel(.xerophagy)
            
        case cal.d("beginningOfGreatLent")+5.days ..< cal.d("palmSunday"):
            return (date == cal.d("annunciation")) ? FastingModel(.fishAllowed) : monasticGreatLent()
            
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
            return monasticApostolesFast()
            
        case cal.d("beginningOfDormitionFast") ... cal.d("dormition")-1.days:
            return monasticGreatLent()
            
        case cal.d("beginningOfNativityFast") ..< stNicholas:
            return monasticApostolesFast()
            
        case stNicholas ... cal.endOfYear:
            return (cal.weekday == .tuesday || cal.weekday == .thursday) ? FastingModel(.withOil) : monasticApostolesFast()
            
        default:
            if (cal.weekday == .monday || cal.weekday == .wednesday || cal.weekday == .friday) {
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
    
    func meetingOfLord(_ date: Date, monastic: Bool) -> FastingModel {
        if cal.d("sundayOfPublicianAndPharisee")+1.days ... cal.d("sundayOfProdigalSon") ~= date {
            return FastingModel(.fastFree)
            
        } else if cal.d("sundayOfDreadJudgement")+1.days ..< cal.d("beginningOfGreatLent") ~= date {
            return FastingModel(.cheesefare)
            
        } else if date == cal.d("beginningOfGreatLent") {
            return monastic ? FastingModel(.noFood) : FastingModel(.vegetarian, "Great Lent")
            
        } else {
            return (cal.weekday == .monday ||
                cal.weekday == .wednesday ||
                cal.weekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(monastic ? .noFastMonastic : .noFast)
        }
    }
    
    func monasticGreatLent() -> FastingModel {
        switch cal.weekday {
        case .monday, .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday:
            return FastingModel(.withoutOil)
            
        case .saturday, .sunday:
            return FastingModel(.withOil)
        }
    }
    
    func monasticApostolesFast() -> FastingModel {
        switch cal.weekday {
        case .monday:
            return FastingModel(.withoutOil)
            
        case .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday, .saturday, .sunday:
            return FastingModel(.fishAllowed)
            
        }
    }
}


