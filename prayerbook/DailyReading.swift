//
//  DailyReading.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 03.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct DailyReading {
    
    static let specialReadings : [NameOfDay: String] = [
        .nativityOfTheotokos:       "Luke 1:39-49,56 Phil 2:5-11 Luke 10:38-42,11:27-28",
        .saturdayBeforeExaltation:  "1Cor 2:6-9 Matthew 10:37-11:1",
        .sundayBeforeExaltation:    "Gal 6:11-18 John 3:13-17",
        .exaltationOfCross:         "John 12:28-36 1Cor 1:18-24 John 19:6-11,13-20,25-28,30-35",
        .saturdayAfterExaltation:   "1Cor 1:26-29 John 8:21-30",
        .sundayAfterExaltation:     "Gal 2:16-20 Mark 8:34-9:1",
        .veilOfTheotokos:                      "Luke 1:39-49,56 Heb 9:1-7 Luke 10:38-42,11:27-28",
        .entryIntoTemple:           "Luke 1:39-49,56 Heb 9:1-7 Luke 10:38-42,11:27-28",
        .stNicholas:                "John 10:9-16 Heb 13:17-21 Luke 6:17-23",
        .sundayOfForefathers:       "Col 3:4-11 Luke 14:16-24",
        .saturdayBeforeNativity:    "Gal 3:8-12 Luke 13:18-29",
        .sundayBeforeNativity:           "Heb 11:9-10,17-23,32-40 Matthew 1:1-25",
        .eveOfNativityOfGod:        "Heb 1:1-12 Luke 2:1-20|Gal 3:15-22 Matthew 13:31-36",
        .nativityOfGod:             "Matthew 1:18-25 Gal 4:4-7 Matthew 2:1-12",
        .saturdayAfterNativity:     "1Tim 6:11-16 Matthew 12:15-21",
        .sundayAfterNativity:       "Gal 1:11-19 Matthew 2:13-23",
        .circumcision:              "John 10:1-9 Col 2:8-12 Luke 2:20-21,40-52",
        .saturdayBeforeTheophany:   "1Tim 3:14-4:5 Matthew 3:1-11",
        .sundayBeforeTheophany:     "2Tim 4:5-8 Mark 1:1-8",
        .eveOfTheophany:            "1Cor 9:19-27 Luke 3:1-18",
        .theophany:                 "Mark 1:9-11 Tit 2:11-14,3:4-7 Matthew 3:13-17",
        .saturdayAfterTheophany:    "Ephes 6:10-17 Matthew 4:1-11",
        .sundayAfterTheophany:      "Ephes 4:7-13 Matthew 4:12-17",
        .meetingOfLord:             "Luke 2:25-32 Heb 7:7-17 Luke 2:22-40",
        .annunciation:              "Luke 1:39-49,56 Heb 2:11-18 Luke 1:24-38",
        .nativityOfJohn:            "Luke 1:24-25,57-68,76,80 Rom 13:12-14:4 Luke 1:5-25,57-68,76,80",
        .peterAndPaul:              "1Cor 4:9-16 Mark 3:13-19",
        .transfiguration:           "Luke 9:28-36 2Pet 1:10-19 Matthew 17:1-9",
        .dormition:                 "Luke 1:39-49,56 Phil 2:5-11 Luke 10:38-42,11:27-28",
        .beheadingOfJohn:           "Matthew 14:1-13 Acts 13:25-32 Mark 6:14-30",
    ]
    
    static let cancelReading : [NameOfDay] = [.sundayOfForefathers, .sundayBeforeNativity, .eveOfNativityOfGod, .nativityOfGod,
        .sundayAfterNativity, .circumcision, .sundayBeforeTheophany, .eveOfTheophany, .theophany]
    
    static let transferredReading : [NameOfDay] = [.exaltationOfCross, .transfiguration]

    static func GospelOfLent(_ date: Date) -> String {
        let bundle = Bundle.main.path(forResource: "ReadingLent", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as! [String]

        let dayNum = Cal.d(.sundayOfPublicianAndPharisee) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfJohn(_ date: Date) -> String {
        let bundle = Bundle.main.path(forResource: "ReadingJohn", ofType: "plist")
        let readings = NSArray(contentsOfFile: bundle!) as! [String]
        
        let dayNum = Cal.d(.pascha) >> date;
        return readings[dayNum]
    }
    
    static func GospelOfMatthew(_ date: Date) -> String {
        let bundleApostle = Bundle.main.path(forResource: "ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]

        let bundleMatthew = Bundle.main.path(forResource: "ReadingMatthew", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleMatthew!) as! [String]

        var dayNum = (Cal.d(.pentecost)+1.days) >> date;
        var readings = apostle[dayNum] + " "
        
        if dayNum >= 17*7 {
            NSLog("matt exceeding 17 weeks by \(dayNum-17*7+1) days")
            dayNum = dayNum - 7*7
        }
        
        readings += gospel[dayNum]
        return readings
    }
    
    static func GospelOfLukeSpring(_ date: Date) -> String {
        let bundleApostle = Bundle.main.path(forResource: "ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]
        
        let bundleLuke = Bundle.main.path(forResource: "ReadingLuke", ofType: "plist")
        let gospelLuke = NSArray(contentsOfFile: bundleLuke!) as! [String]

        let bundleMatthew = Bundle.main.path(forResource: "ReadingMatthew", ofType: "plist")
        let gospelMatthew = NSArray(contentsOfFile: bundleMatthew!) as! [String]

        var gospelIndex:Int, apostleIndex:Int
        let PAPSunday = Cal.d(.sundayOfPublicianAndPharisee)
        let daysFromPentecost = (Cal.paschaDay(Cal.currentYear-1) + 50.days) >> date
        
        let exaltationPrevYear = Date(27, 9, Cal.currentYear-1)
        let exaltationPrevYearWeekday = DateComponents(date: exaltationPrevYear).weekday!
        let sundayAfterExaltationPrevYear = exaltationPrevYear + (8-exaltationPrevYearWeekday).days
        
        let daysFromExaltation = (sundayAfterExaltationPrevYear+1.days) >> date
        let endOfLukeReadings = sundayAfterExaltationPrevYear+112.days
        let totalOffset = endOfLukeReadings >> PAPSunday
        
        let daysBeforePAP = date >> PAPSunday
        
        if daysFromExaltation >= 16*7-1 {
            
            // need more than three additional Sundays, use 17th week Matthew readings
            if totalOffset > 28 {
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

    static func GospelOfLukeFall(_ date: Date) -> String {
        let bundleApostle = Bundle.main.path(forResource: "ReadingApostle", ofType: "plist")
        let apostle = NSArray(contentsOfFile: bundleApostle!) as! [String]
        
        let bundleLuke = Bundle.main.path(forResource: "ReadingLuke", ofType: "plist")
        let gospel = NSArray(contentsOfFile: bundleLuke!) as! [String]

        // Sunday of Forefathers: Epistle (29th Sunday), Gospel (28th Sunday)
        if (date == Cal.d(.sundayOfForefathers)) {
            return apostle[202] + " " + gospel[76]
        }
        
        var daysFromPentecost = (Cal.d(.pentecost)+1.days) >> date
        var daysFromLukeStart = (Cal.d(.sundayAfterExaltation)+1.days) >> date

        // On 29th Sunday borrow Epistle from Sunday of Forefathers
        if (daysFromPentecost == 202) {
            daysFromPentecost = (Cal.d(.pentecost)+1.days) >> Cal.d(.sundayOfForefathers)
        }
        
        // On 28th Sunday borrow Gospel from Sunday of Forefathers
        if (daysFromLukeStart == 76) {
            daysFromLukeStart = (Cal.d(.sundayAfterExaltation)+1.days) >> Cal.d(.sundayOfForefathers)
        }
        
        return apostle[daysFromPentecost] + " " + gospel[daysFromLukeStart]
    }
    
    static func getRegularReading(_ date: Date) -> String? {
        Cal.setDate(date)
        
        let exaltation = Date(27, 9, Cal.currentYear)
        let exaltationWeekday = DateComponents(date: exaltation).weekday!
        let exaltationFriOffset = (exaltationWeekday >= 6) ? 13-exaltationWeekday : 6-exaltationWeekday
        let fridayAfterExaltation = exaltation + exaltationFriOffset.days
        
        switch (date) {
        case Cal.d(.startOfYear) ..< Cal.d(.sundayOfPublicianAndPharisee):
            return GospelOfLukeSpring(date)
            
        case Cal.d(.sundayOfPublicianAndPharisee) ..< Cal.d(.pascha):
            let reading = GospelOfLent(date)
            return reading.characters.count > 0 ? reading : nil
            
        case Cal.d(.pascha) ... Cal.d(.pentecost):
            return GospelOfJohn(date)
            
        case Cal.d(.pentecost)+1.days ... fridayAfterExaltation:
            return GospelOfMatthew(date)
            
        case Cal.d(.sundayAfterExaltation)+1.days ... Cal.d(.endOfYear):
            return GospelOfLukeFall(date)
            
        default: return nil
        }
    }

    static func transferReading(_ date: Date) -> Date? {
        let weekday = DateComponents(date:date).weekday
        var newDate:Date
        
        if weekday == 1 {
            return nil
            
        } else if weekday == 2 {
            newDate = date+1.days
            
        } else {
            newDate = date - 1.days
        }
        
        return newDate
    }
    
    static func getDailyReading(_ date: Date) -> [String] {
        
        var readings = [String]()
        var transferred = [Date:String]()
        var noRegularReading = false

        for code in transferredReading {
            if let newDate = transferReading(Cal.d(code)) {
                transferred[newDate] = getRegularReading(Cal.d(code))
            }
        }
        
        if let feastCodes = Cal.feastDates[date] {
            for code in feastCodes {
                
                if cancelReading.contains(code) || transferredReading.contains(code)  {
                    noRegularReading = true
                }
                
                if Array(specialReadings.keys).contains(code) {
                    if (code == .eveOfNativityOfGod) {
                        
                        let choices = specialReadings[code]!.components(separatedBy: "|")
                        let weekday = DateComponents(date:date).weekday
                        readings.append((weekday == 7 || weekday == 1) ? choices[1] : choices[0])

                    } else {
                        readings += [specialReadings[code]!]
                        
                    }
                }
            }
        }
        
        var regularReading = [String]()
        
        if let reading = getRegularReading(date) {
                regularReading = [reading]
        }

        if readings.count > 0 {
            if !noRegularReading {
                readings += regularReading
            }
            return readings
            
        } else {
            if let reading=transferred[date] {
                return regularReading + [reading]
            } else {
                return regularReading
            }
        }
    }
    
    static func decorateLine(_ verse:Int64, _ content:String, _ fontSize:Int) -> NSMutableAttributedString {
        var text : NSMutableAttributedString? = nil
        text = text + ("\(verse) ", UIColor.red)
        text = text + (content, UIColor.black)
        text = text + "\n"
        
        text!.addAttribute(NSFontAttributeName,
            value: UIFont.systemFont(ofSize: CGFloat(fontSize)),
            range: NSMakeRange(0, text!.length))
        
        return text!
    }
    
    static func getPericope(_ str: String, decorated: Bool, fontSize: Int = 0) -> [(NSMutableAttributedString, NSMutableAttributedString)] {
        var result = [(NSMutableAttributedString, NSMutableAttributedString)]()
        
        var pericope = str.characters.split { $0 == " " }.map { String($0) }
        
        for i in stride(from: 0, to: pericope.count-1, by: 2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercased()
            let bookTuple = (NewTestament+OldTestament).filter { $0.1 == fileName }
            
            let centerStyle = NSMutableParagraphStyle()
            centerStyle.alignment = .center
            
            var bookName:NSMutableAttributedString
            var text : NSMutableAttributedString? = nil

            if decorated {
                bookName = NSMutableAttributedString(
                    string: Translate.s(bookTuple[0].0) + " " + pericope[i+1],
                    attributes: [NSParagraphStyleAttributeName: centerStyle,
                        NSFontAttributeName: UIFont.boldSystemFont(ofSize: CGFloat(fontSize)) ])
                
            } else {
                bookName = NSMutableAttributedString(string: Translate.s(bookTuple[0].0))
            }

            let arr2 = pericope[i+1].components(separatedBy: ",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                let arr3 = segment.components(separatedBy: "-")
                for offset in arr3 {
                    var arr4 = offset.components(separatedBy: ":")
                    
                    if arr4.count == 1 {
                        range += [ (chapter, Int(arr4[0])!) ]
                        
                    } else {
                        chapter = Int(arr4[0])!
                        range += [ (chapter, Int(arr4[1])!) ]
                    }
                }
                
                if range.count == 1 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse=\(range[0].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize )
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                } else if range[0].0 != range[1].0 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                    for chap in range[0].0+1 ..< range[1].0 {
                        for line in Db.book(fileName, whereExpr: "chapter=\(chap)") {
                            if decorated {
                                text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                            } else {
                                text = text + (line["text"] as! String) + " "
                            }
                        }
                    }
                    
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[1].0) AND verse<=\(range[1].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                } else {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1) AND verse<=\(range[1].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                }
            }
            
            text = text + "\n"
            result += [(bookName, text!)]
        }

        return result
    }
    
}
