//
//  FastingModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/3/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public enum FastingLevel: Int {
    case laymen=0, monastic
    
    init() {
        let prefs = UserDefaults(suiteName: groupId)!
        self = FastingLevel(rawValue: prefs.integer(forKey: "fastingLevel"))!
    }
    
    func save() {
        let prefs = UserDefaults(suiteName: groupId)!
        prefs.set(self.rawValue, forKey: "fastingLevel")
        prefs.synchronize()
    }
}

public enum FastingType: Int {
    case noFast=0, vegetarian, fishAllowed, fastFree, cheesefare, noFood, xerophagy, withoutOil, withOil, noFastMonastic
}

struct FastingModel {
    let type: FastingType
    let descr: String
    let comments: String?
    let icon: String
    let color: UIColor
    
    static let fastingColor : [FastingType: UIColor] = [
        .noFast:            .clear,
        .noFastMonastic:    .clear,
        .vegetarian:    UIColor(hex: "#30D5C8"),
        .fishAllowed:   UIColor(hex: "#FF9933"),
        .fastFree:      UIColor(hex: "#00BFFF"),
        .cheesefare:    UIColor(hex: "#00BFFF"),
        .noFood:        UIColor(hex: "#7B78EE"),
        .xerophagy:     UIColor(hex: "#B4EEB4"),
        .withoutOil:    UIColor(hex: "#9BCD9B"),
        .withOil:       UIColor(hex: "#30D5C8"),
    ]
    
    static let fastingDescr : [FastingType: String] = [
        .noFast:            "No fast",
        .noFastMonastic:    "No fast",
        .vegetarian:    "Vegetarian",
        .fishAllowed:   "Fish allowed",
        .fastFree:      "Fast-free week",
        .cheesefare:    "Maslenitsa",
        .noFood:        "No food",
        .xerophagy:     "Xerophagy",
        .withoutOil:    "Without oil",
        .withOil:       "With oil",
    ]
    
    static var fastingIcon: [FastingType: String] = [
        .noFast:        "burger",
        .noFastMonastic:"mexican",
        .vegetarian:    "vegetables",
        .fishAllowed:   "fish",
        .fastFree:      "cupcake",
        .cheesefare:    "pancake",
        .noFood:        "nothing",
        .xerophagy:     "fruits",
        .withoutOil:    "without-oil",
        .withOil:       "vegetables",
    ]
    
    static var fastingComments = [String:String]()
    
    static let monasticTypes : [FastingModel] = [
        FastingModel(.noFood), FastingModel(.xerophagy),
        FastingModel(.withoutOil), FastingModel(.withOil),
        FastingModel(.fishAllowed), FastingModel(.fastFree)]
    
    static let laymenTypes: [FastingModel] = [
        FastingModel(.vegetarian), FastingModel(.fishAllowed), FastingModel(.fastFree)
    ]
    
    init(_ type: FastingType, _ descr: String? = nil) {
        self.type = type
        self.color = FastingModel.fastingColor[type]!
        
        if let descr = descr {
            self.descr = Translate.s(descr)
        } else {
            self.descr = Translate.s(FastingModel.fastingDescr[type]!)
        }
        
        self.icon = FastingModel.fastingIcon[type]!
        self.comments = FastingModel.fastingComments[self.descr]
    }
    
    static func fasting(forDate date: Date) -> FastingModel{
        Cal.setDate(date)
        
        switch FastingLevel() {
        case .laymen:
            return getFastingLaymen(date)
            
        case .monastic:
            return getFastingMonastic(date)
        }
    }
    
    static func monasticGreatLent() -> FastingModel {
        switch Cal.currentWeekday {
        case .monday, .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday:
            return FastingModel(.withoutOil)
            
        case .saturday, .sunday:
            return FastingModel(.withOil)
        }
    }
    
    static func monasticApostolesFast() -> FastingModel {
        switch Cal.currentWeekday {
        case .monday:
            return FastingModel(.withoutOil)
            
        case .wednesday, .friday:
            return FastingModel(.xerophagy)
            
        case .tuesday, .thursday, .saturday, .sunday:
            return FastingModel(.fishAllowed)
            
        }
    }
    
    static func getFastingMonastic(_ date: Date) -> FastingModel {
        switch date {
        case Cal.d(.meetingOfLord):
            if Cal.d(.beginningOfGreatLent)-7.days ... Cal.d(.beginningOfGreatLent)-1.days ~= date {
                return FastingModel(.cheesefare)
                
            } else if date == Cal.d(.beginningOfGreatLent) {
                return FastingModel(.noFood)
                
            } else {
                return (Cal.currentWeekday == .monday ||
                    Cal.currentWeekday == .wednesday ||
                    Cal.currentWeekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFastMonastic)
            }
            
        case Cal.d(.theophany):
            return FastingModel(.noFastMonastic)
            
        case Cal.d(.nativityOfTheotokos),
             Cal.d(.peterAndPaul),
             Cal.d(.dormition),
             Cal.d(.veilOfTheotokos):
            return (Cal.currentWeekday == .monday ||
                Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFastMonastic)
            
        case Cal.d(.nativityOfJohn),
             Cal.d(.transfiguration),
             Cal.d(.entryIntoTemple),
             Cal.d(.stNicholas),
             Cal.d(.palmSunday):
            return FastingModel(.fishAllowed)
            
        case Cal.d(.eveOfTheophany):
            return FastingModel(.xerophagy, "Fast day")
            
        case Cal.d(.beheadingOfJohn),
             Cal.d(.exaltationOfCross):
            return FastingModel(.withOil, "Fast day")
            
        case Cal.d(.startOfYear):
            return (Cal.currentWeekday == .tuesday || Cal.currentWeekday == .thursday) ?
                FastingModel(.withOil) : monasticApostolesFast()
            
        case Cal.d(.startOfYear)+1.days ..< Cal.d(.nativityOfGod):
            return monasticGreatLent()
            
        case Cal.d(.nativityOfGod) ..< Cal.d(.eveOfTheophany):
            return FastingModel(.fastFree, "Svyatki")
            
        case Cal.d(.sundayOfPublicianAndPharisee)+1.days ... Cal.d(.sundayOfProdigalSon):
            return FastingModel(.fastFree)
            
        case Cal.d(.sundayOfDreadJudgement)+1.days ..< Cal.d(.beginningOfGreatLent):
            return FastingModel(.cheesefare)
            
        case Cal.d(.beginningOfGreatLent):
            return FastingModel(.noFood)
            
        case Cal.d(.beginningOfGreatLent)+1.days ... Cal.d(.beginningOfGreatLent)+4.days:
            return FastingModel(.xerophagy)
            
        case Cal.d(.beginningOfGreatLent)+5.days ..< Cal.d(.palmSunday):
            return (date == Cal.d(.annunciation)) ? FastingModel(.fishAllowed) : monasticGreatLent()
            
        case Cal.d(.palmSunday)+1.days ... Cal.d(.palmSunday)+4.days:
            return FastingModel(.xerophagy)
            
        case Cal.d(.palmSunday)+5.days:
            return FastingModel(.noFood)
            
        case Cal.d(.palmSunday)+6.days:
            return FastingModel(.withOil)
            
        case Cal.d(.pascha)+1.days ... Cal.d(.pascha)+7.days:
            return FastingModel(.fastFree)
            
        case Cal.d(.pentecost)+1.days ... Cal.d(.pentecost)+7.days:
            return FastingModel(.fastFree)
            
        case Cal.d(.beginningOfApostolesFast) ... Cal.d(.peterAndPaul)-1.days:
            return monasticApostolesFast()
            
        case Cal.d(.beginningOfDormitionFast) ... Cal.d(.dormition)-1.days:
            return monasticGreatLent()
            
        case Cal.d(.beginningOfNativityFast) ..< Cal.d(.stNicholas):
            return monasticApostolesFast()
            
        case Cal.d(.stNicholas) ... Cal.d(.endOfYear):
            return (Cal.currentWeekday == .tuesday || Cal.currentWeekday == .thursday) ? FastingModel(.withOil) : monasticApostolesFast()
            
        default:
            if (Cal.currentWeekday == .monday || Cal.currentWeekday == .wednesday || Cal.currentWeekday == .friday) {
                let saints = Db.saints(date)
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
    
    static func getFastingLaymen(_ date: Date) -> FastingModel {
        switch date {
        case Cal.d(.meetingOfLord):
            if Cal.d(.beginningOfGreatLent)-7.days ... Cal.d(.beginningOfGreatLent)-1.days ~= date {
                return FastingModel(.cheesefare)
                
            } else if date == Cal.d(.beginningOfGreatLent) {
                return FastingModel(.vegetarian, "Great Lent")
                
            } else {
                return (Cal.currentWeekday == .wednesday ||
                    Cal.currentWeekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFast)
            }
            
        case Cal.d(.theophany):
            return FastingModel(.noFast)
            
        case Cal.d(.nativityOfTheotokos),
             Cal.d(.peterAndPaul),
             Cal.d(.dormition),
             Cal.d(.veilOfTheotokos):
            return (Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFast)
            
        case Cal.d(.nativityOfJohn),
             Cal.d(.transfiguration),
             Cal.d(.entryIntoTemple),
             Cal.d(.stNicholas),
             Cal.d(.palmSunday):
            return FastingModel(.fishAllowed)
            
        case Cal.d(.eveOfTheophany),
             Cal.d(.beheadingOfJohn),
             Cal.d(.exaltationOfCross):
            return FastingModel(.vegetarian, "Fast day")
            
        case Cal.d(.startOfYear):
            return (Cal.currentWeekday == .saturday ||
                Cal.currentWeekday == .sunday) ? FastingModel(.fishAllowed, "Nativity Fast") : FastingModel(.vegetarian, "Nativity Fast")
            
        case Cal.d(.startOfYear)+1.days ..< Cal.d(.nativityOfGod):
            return FastingModel(.vegetarian, "Nativity Fast")
            
        case Cal.d(.nativityOfGod) ..< Cal.d(.eveOfTheophany):
            return FastingModel(.fastFree, "Svyatki")
            
        case Cal.d(.sundayOfPublicianAndPharisee)+1.days ... Cal.d(.sundayOfProdigalSon):
            return FastingModel(.fastFree)
            
        case Cal.d(.sundayOfDreadJudgement)+1.days ..< Cal.d(.beginningOfGreatLent):
            return FastingModel(.cheesefare)
            
        case Cal.d(.beginningOfGreatLent) ..< Cal.d(.palmSunday):
            return (date == Cal.d(.annunciation)) ? FastingModel(.fishAllowed) : FastingModel(.vegetarian, "Great Lent")
            
        case Cal.d(.palmSunday)+1.days ..< Cal.d(.pascha):
            return FastingModel(.vegetarian)
            
        case Cal.d(.pascha)+1.days ... Cal.d(.pascha)+7.days:
            return FastingModel(.fastFree)
            
        case Cal.d(.pentecost)+1.days ... Cal.d(.pentecost)+7.days:
            return FastingModel(.fastFree)
            
        case Cal.d(.beginningOfApostolesFast) ... Cal.d(.peterAndPaul)-1.days:
            return (Cal.currentWeekday == .monday ||
                Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.vegetarian, "Apostoles' Fast") : FastingModel(.fishAllowed, "Apostoles' Fast")
            
        case Cal.d(.beginningOfDormitionFast) ... Cal.d(.dormition)-1.days:
            return FastingModel(.vegetarian, "Dormition Fast")
            
        case Cal.d(.beginningOfNativityFast) ..< Cal.d(.stNicholas):
            return (Cal.currentWeekday == .monday ||
                Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.vegetarian, "Nativity Fast") : FastingModel(.fishAllowed, "Nativity Fast")
            
        case Cal.d(.stNicholas) ... Cal.d(.endOfYear):
            return (Cal.currentWeekday == .saturday ||
                Cal.currentWeekday == .sunday) ? FastingModel(.fishAllowed, "Nativity Fast") : FastingModel(.vegetarian, "Nativity Fast")
            
        case Cal.d(.nativityOfGod) ..< Cal.d(.pentecost)+8.days:
            return (Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.fishAllowed) : FastingModel(.noFast)
            
        default:
            return (Cal.currentWeekday == .wednesday ||
                Cal.currentWeekday == .friday) ? FastingModel(.vegetarian) : FastingModel(.noFast)
        }
    }
}

