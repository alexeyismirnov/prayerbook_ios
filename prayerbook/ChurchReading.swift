//
//  ChurchReading.swift
//  ponomar
//
//  Created by Alexey Smirnov on 1/29/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

extension Array {
    static func fromPList(_ name: String) -> [String] {
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")!
        return NSArray(contentsOfFile: toolkit.path(forResource: name, ofType: "plist")!) as! [String]
    }
}

struct LukeSpringParams {
    var PAPSunday : Date
    var pentecostPrevYear : Date
    var sundayAfterExaltationPrevYear : Date
    var totalOffset : Int
    
    init(_ cal: Cal2) {
        self.PAPSunday = cal.d("sundayOfPublicianAndPharisee")
        self.pentecostPrevYear = Cal2.paschaDay(cal.year-1) + 50.days
        
        let exaltationPrevYear = Date(27, 9, cal.year-1)
        let exaltationPrevYearWeekday = DateComponents(date: exaltationPrevYear).weekday!
        self.sundayAfterExaltationPrevYear = exaltationPrevYear + (8-exaltationPrevYearWeekday).days

        let endOfLukeReadings = self.sundayAfterExaltationPrevYear+112.days
        self.totalOffset = endOfLukeReadings >> self.PAPSunday
    }
}

public class ChurchReading {
    var cal: Cal2
    static var models = [Int:ChurchReading]()
    
    var LS: LukeSpringParams
    var apostle, readingsJohn, gospelMatthew, gospelLuke, readingsLent : [String]
    var rr = [Date:[String]]()
   
    init(_ date: Date) {
        cal = Cal2.fromDate(date)
        LS = LukeSpringParams(cal)

        apostle = [String].fromPList("ReadingApostle")
        readingsJohn = [String].fromPList("ReadingJohn")
        gospelMatthew = [String].fromPList("ReadingMatthew")
        gospelLuke = [String].fromPList("ReadingLuke")
        readingsLent = [String].fromPList("ReadingLent")
        
        generateRR()
        generateTransfers()
    }
    
    func generateRR() {
        for d in DateRange(cal.startOfYear, cal.endOfYear) {
            if let r = getRegularReading(d) {
                rr[d] = [r]
            }
        }
    }
    
    func generateTransfers() {
        let feasts = cal.getAllReadings()

        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "cccc"
        formatter.locale = Locale(identifier: "en")
        
        // Christmas' and Theophany's Eves and Feasts have their own readings
        rr[Date(7, 1, cal.year)] = nil
        rr[Date(6, 1, cal.year)] = nil
        rr[Date(18, 1, cal.year)] = nil
        rr[Date(19, 1, cal.year)] = nil

        for feast in feasts {
            if cal.greatLentStart ... cal.pentecost ~= feast.date! {
                continue
            }
            
            if feast.type == .great {
                let oldDate = feast.date!
                
                if let oldReading = rr[oldDate],
                    let newDate = transferGreatFeast(oldDate) {
                    let comment =  String(format: "# %@ Reading", formatter.string(from: oldDate))
                    
                    for r in oldReading {
                        rr[newDate]?.append(String(format: "%@ %@", r, comment))
                    }
                    
                    rr[oldDate] = nil
                }
                
            } else if feast.type == .vigil {
                let oldDate = feast.date!
                
                if let oldReading = rr[oldDate],
                    let newDate = transferVigil(oldDate) {
                    if newDate != oldDate {
                        let comment =  String(format: "# %@ Reading", formatter.string(from: oldDate))
                        for r in oldReading {
                            rr[newDate]?.append(String(format: "%@ %@", r, comment))
                        }
                        
                        rr[oldDate] = nil
                    }
                }
            }
            
        }
    }
    
    func transferGreatFeast(_ date: Date) -> Date? {
        let weekday = DayOfWeek(date:date)
        var newDate:Date

        if weekday == .sunday {
            return nil
            
        } else if weekday == .monday {
            newDate = date + 1.days
            
            if cal.getDayReadings(newDate).count > 0 {
                return nil
            }
            
        } else {
            newDate = date - 1.days
            
            if cal.getDayReadings(newDate).count > 0 {
                return nil
            }
        }
        
        return newDate
    }
    
    func transferVigil(_ date: Date) -> Date? {
        let weekday = DayOfWeek(date:date)
        var newDate:Date

        if weekday == .sunday {
            return date
            
        } else if weekday == .monday {
            newDate = date + 1.days
            
            if cal.getDayReadings(newDate).count > 0 {
                return date
            }
            
        } else {
            newDate = date - 1.days
            
            if cal.getDayReadings(newDate).count > 0 {
                newDate = date + 1.days
                
                if weekday == .saturday || cal.getDayReadings(newDate).count > 0 {
                    return date
                }
            }
        }
        
        return newDate
    }
    
    func GospelOfLent(_ date: Date) -> String {
        let dayNum = cal.d("sundayOfPublicianAndPharisee") >> date;
        return readingsLent[dayNum]
    }
    
    func GospelOfJohn(_ date: Date) -> String {
        let dayNum = cal.pascha >> date;
        return readingsJohn[dayNum]
    }
    
    func GospelOfMatthew(_ date: Date) -> String {
        var dayNum = (cal.pentecost+1.days) >> date;
        var readings = apostle[dayNum] + " "
        
        if dayNum >= 17*7 {
            //  NSLog("matt exceeding 17 weeks by \(dayNum-17*7+1) days")
            dayNum = dayNum - 7*7
        }
        
        readings += gospelMatthew[dayNum]
        return readings
    }
    
    func GospelOfLukeSpring(_ date: Date) -> String {
        var gospelIndex:Int, apostleIndex:Int
                
        let daysFromPentecost = LS.pentecostPrevYear >> date
        let daysFromExaltation = (LS.sundayAfterExaltationPrevYear+1.days) >> date
        let daysBeforePAP = date >> LS.PAPSunday
        
        if daysFromExaltation >= 16*7-1 {
            // need more than three additional Sundays, use 17th week Matthew readings
            if LS.totalOffset > 28 {
                if daysBeforePAP < 21 && daysBeforePAP >= 14 {
                    let indexMatthew = 118 - (daysBeforePAP-14)
                    return apostle[indexMatthew] + " " + gospelMatthew[indexMatthew]

                } else if daysBeforePAP >= 21 {
                    gospelIndex = 118 - daysBeforePAP
                    apostleIndex = 237 - daysBeforePAP
                    return apostle[apostleIndex] + " " + gospelLuke[gospelIndex]
                }
            }
            
            gospelIndex = 111 - daysBeforePAP
            apostleIndex = 230 - daysBeforePAP
            
        } else if daysFromPentecost >= 33*7-1 {
            gospelIndex = daysFromExaltation
            apostleIndex = 230 - daysBeforePAP

        } else {
            gospelIndex = daysFromExaltation
            apostleIndex = daysFromPentecost
        }
        
        return apostle[apostleIndex] + " " + gospelLuke[gospelIndex]
    }

    func GospelOfLukeFall(_ date: Date) -> String {
        // Sunday of Forefathers: Epistle (29th Sunday), Gospel (28th Sunday)
        if (date == cal.d("sundayOfForefathers")) {
            return apostle[202] + " " + gospelLuke[76]
        }
        
        var daysFromPentecost = (cal.pentecost+1.days) >> date
        var daysFromLukeStart = (cal.d("sundayAfterExaltation")+1.days) >> date

        // On 29th Sunday borrow Epistle from Sunday of Forefathers
        if (daysFromPentecost == 202) {
            daysFromPentecost = (cal.pentecost+1.days) >> cal.d("sundayOfForefathers")
        }
        
        // On 28th Sunday borrow Gospel from Sunday of Forefathers
        if (daysFromLukeStart == 76) {
            daysFromLukeStart = (cal.d("sundayAfterExaltation")+1.days) >> cal.d("sundayOfForefathers")
        }
        
        return apostle[daysFromPentecost] + " " + gospelLuke[daysFromLukeStart]
    }
    
    public func getRegularReading(_ date: Date) -> String? {
        switch (date) {
        case cal.startOfYear ..< cal.d("sundayOfPublicianAndPharisee"):
            return GospelOfLukeSpring(date)
            
        case cal.d("sundayOfPublicianAndPharisee") ..< cal.pascha:
            let reading = GospelOfLent(date)
            return reading.count > 0 ? reading : nil
            
        case cal.pascha ... cal.pentecost:
            return GospelOfJohn(date)
            
        case cal.pentecost+1.days ... cal.d("sundayAfterExaltation"):
            return GospelOfMatthew(date)
            
        case cal.d("sundayAfterExaltation")+1.days ... cal.endOfYear:
            return GospelOfLukeFall(date)
            
        default: return nil
        }
    }
    
    func getDailyReading(_ date: Date) -> [String] {
        let feasts = cal.getDayReadings(date)
        
        if feasts.count > 0 {
            if feasts[0].type == .great {
                return feasts.filter({ $0.type == .great }).map { $0.reading }
                
            } else {
                return feasts.map({ $0.reading }) + (rr[date] ?? [])
            }
            
        } else {
            return rr[date] ?? []
        }
        
        return []
    }
    
    static public func forDate(_ date: Date) -> [String] {
        let dateComponents = DateComponents(date: date)
        let year = dateComponents.year!
        
        if models[year] == nil {
            models[year] = ChurchReading(date)
        }
        
        return models[year]!.getDailyReading(date)
    }
    
}

