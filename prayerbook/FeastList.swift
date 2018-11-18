//
//  FeastList.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/29/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

struct FeastList {
    static let formatter1: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "cccc, d MMMM"
        formatter.locale = Locale(identifier: "ru")
        
        return formatter
    }()
    
    static let formatter2: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateFormat = "d MMMM"
        formatter.locale = Locale(identifier: "ru")
        
        return formatter
    }()
    
    static var sharing: Bool {
        set { textFontSize = newValue ? CGFloat(12) : CGFloat(16)
            textFontColor = newValue ? UIColor.black :Theme.textColor
        }
        get { return false }
    }
    
    static var textFontSize : CGFloat!
    static var textFontColor : UIColor!
    
    static var longFasts : [Date: NSAttributedString]!
    static var shortFasts : [Date: NSAttributedString]!
    static var fastFreeWeeks : [Date: NSAttributedString]!
    static var movableFeasts : [Date: NSAttributedString]!
    static var nonMovableFeasts : [Date: NSAttributedString]!
    static var greatFeasts : [Date: NSAttributedString]!
    static var remembrance : [Date: NSAttributedString]!
    
    static func makeFeastStr(code: NameOfDay, color: UIColor? = nil) -> NSAttributedString  {
        let dateStr = formatter1.string(from: Cal.d(code)).capitalizingFirstLetter()
        let feastStr = Translate.s(Cal.codeFeastDescr[code]!.1)
        
        return "\(dateStr) — \(feastStr)\n\n".colored(with: color ?? textFontColor).systemFont(ofSize: textFontSize)
    }
    
    static func makeLentStr(fromDate: Date, toDate: Date, descr : String) -> NSAttributedString  {
        let d1 = formatter2.string(from: fromDate)
        let d2 = formatter2.string(from: toDate)
        
        return "С \(d1) по \(d2) — \(descr)\n\n".colored(with: textFontColor).systemFont(ofSize: textFontSize)
    }
    
    static func setDate(_ date: Date) {
        Cal.setDate(Date(1, 1, date.year))
        
        longFasts = [
            Cal.d(.beginningOfGreatLent) : makeLentStr(fromDate: Cal.d(.beginningOfGreatLent),
                                                       toDate: Cal.d(.beginningOfGreatLent) + 47.days,
                                                       descr: "Великий пост"),
            
            Cal.d(.beginningOfApostolesFast) : makeLentStr(fromDate: Cal.d(.beginningOfApostolesFast),
                                                           toDate: Cal.d(.peterAndPaul) - 1.days,
                                                           descr: "Петров пост"),
            
            Cal.d(.beginningOfDormitionFast) : makeLentStr(fromDate: Cal.d(.beginningOfDormitionFast),
                                                           toDate: Cal.d(.dormition) - 1.days,
                                                           descr: "Успенский пост"),
            
            Cal.d(.beginningOfNativityFast) : makeLentStr(fromDate: Cal.d(.beginningOfNativityFast),
                                                          toDate: Cal.d(.nativityOfGod) - 1.days,
                                                          descr: "Рождественский пост")]
        
        shortFasts = [Cal.d(.eveOfTheophany) :  makeFeastStr(code: .eveOfTheophany),
                      Cal.d(.beheadingOfJohn) :  makeFeastStr(code: .beheadingOfJohn),
                      Cal.d(.exaltationOfCross) :  makeFeastStr(code: .exaltationOfCross)]
        
        fastFreeWeeks = [
            Cal.d(.nativityOfGod) : makeLentStr(fromDate: Cal.d(.nativityOfGod),
                                                toDate: Cal.d(.eveOfTheophany) - 1.days,
                                                descr: "Святки"),
            
            Cal.d(.sundayOfPublicianAndPharisee)+1.days : makeLentStr(fromDate: Cal.d(.sundayOfPublicianAndPharisee)+1.days,
                                                                      toDate: Cal.d(.sundayOfProdigalSon),
                                                                      descr: "Седмица мытаря и фарисея"),
            
            Cal.d(.sundayOfDreadJudgement)+1.days : makeLentStr(fromDate: Cal.d(.sundayOfDreadJudgement)+1.days,
                                                                toDate: Cal.d(.beginningOfGreatLent)-1.days,
                                                                descr: "Масленица"),
            
            Cal.d(.pascha)+1.days : makeLentStr(fromDate: Cal.d(.pascha)+1.days,
                                                toDate: Cal.d(.pascha)+7.days,
                                                descr: "Светлая седмица"),
            
            Cal.d(.pentecost)+1.days : makeLentStr(fromDate: Cal.d(.pentecost)+1.days,
                                                   toDate: Cal.d(.pentecost)+7.days,
                                                   descr: "Троицкая седмица")]
        
        movableFeasts = Dictionary(uniqueKeysWithValues:
            [.palmSunday, .ascension, .pentecost].map{ (Cal.d($0), makeFeastStr(code: $0)) })
        
        nonMovableFeasts = Dictionary(uniqueKeysWithValues:
            [.nativityOfGod, .theophany, .meetingOfLord, .annunciation, .transfiguration, .dormition,
            .nativityOfTheotokos, .exaltationOfCross, .entryIntoTemple].map{ (Cal.d($0), makeFeastStr(code: $0)) })

        greatFeasts = Dictionary(uniqueKeysWithValues:
            [.circumcision, .nativityOfJohn, .peterAndPaul, .beheadingOfJohn, .veilOfTheotokos].map{ (Cal.d($0), makeFeastStr(code: $0)) })
        
        remembrance = [Cal.d(.newMartyrsConfessorsOfRussia): makeFeastStr(code: .newMartyrsConfessorsOfRussia),
                       Cal.d(.saturdayOfDeparted): makeFeastStr(code: .saturdayOfDeparted),
                       Cal.d(.radonitsa): makeFeastStr(code: .radonitsa),
                       Cal.d(.killedInAction): makeFeastStr(code: .killedInAction),
                       Cal.d(.saturdayTrinity): makeFeastStr(code: .saturdayTrinity),
                       Cal.d(.demetriusSaturday):makeFeastStr(code: .demetriusSaturday)
        ]
    }
    
    
}

typealias FL = FeastList
