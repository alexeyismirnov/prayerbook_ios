//
//  ChurchFasting.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 1/27/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import UIKit

public enum FastingLevel: Int {
    case laymen=0, monastic
}

public enum FastingType: Int {
    case noFast=0, vegetarian, fishAllowed, fastFree, cheesefare, noFood, xerophagy, withoutOil, withOil, noFastMonastic
}

public struct FastingModel {
    public let type: FastingType
    public let descr: String
    public let comments: String?
    public let icon: String
    public let color: UIColor
    
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
        .noFast:            "no_fast",
        .noFastMonastic:    "no_fast",
        .vegetarian:    "vegetarian",
        .fishAllowed:   "fish_allowed",
        .fastFree:      "fast_free",
        .cheesefare:    "maslenitsa",
        .noFood:        "no_food",
        .xerophagy:     "xerophagy",
        .withoutOil:    "without_oil",
        .withOil:       "with_oil",
    ]
    
    static var fastingIcon: [FastingType: String] = [
        .noFast:        "salami",
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
    
    static public var fastingComments = [String:String]()
    
    static public var monasticTypes : [FastingModel] {
        get { return [
            FastingModel(.noFood), FastingModel(.xerophagy),
            FastingModel(.withoutOil), FastingModel(.withOil),
            FastingModel(.fishAllowed), FastingModel(.fastFree)]
        }
    }
    
    static public var laymenTypes: [FastingModel]  {
        get { return [
            FastingModel(.vegetarian), FastingModel(.fishAllowed), FastingModel(.fastFree)
            ]
        }
    }
    
    static public var fastingLevel: FastingLevel!
    
    public init(_ type: FastingType, _ descr: String? = nil) {
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
}

public class ChurchFasting {
    var cal: Cal
    var stNicholas: Date
    
    static var models = [Int:ChurchFasting]()
    
    init(_ date: Date) {
        cal = Cal.fromDate(date)
        stNicholas = Date(19, 12, cal.year)
    }

    static public func forDate(_ date: Date) -> FastingModel {
        let dateComponents = DateComponents(date: date)
        let year = dateComponents.year!
        
        if models[year] == nil {
            models[year] = ChurchFasting(date)
        }
        
        switch FastingModel.fastingLevel ?? .laymen {
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
            if (weekday == .wednesday || weekday == .friday) {
                let saints = SaintModel.saints(date)
                let maxSaint = saints.max { $0.type.rawValue < $1.type.rawValue }!
                
                switch maxSaint.type {
                case .vigil, .polyeleos:
                    return FastingModel(.fishAllowed)
                    
                default:
                    return FastingModel(.vegetarian)
                }
                
            }
            else {
                return FastingModel(.noFast)
            }
           
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
                let maxSaint = saints.max { $0.type.rawValue < $1.type.rawValue }!
                
                switch maxSaint.type {
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
            return monastic ? FastingModel(.xerophagy, "great_lent") : FastingModel(.vegetarian, "great_lent")
            
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


