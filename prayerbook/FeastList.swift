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
        set { textFontSize = newValue ? CGFloat(14) : CGFloat(16)
            textFontColor = newValue ? UIColor.black :Theme.textColor
        }
        get { return false }
    }
    
    static var textFontSize : CGFloat!
    static var textFontColor : UIColor!
    
    static var longFasts : [Date: NSMutableAttributedString]!
    static var shortFasts : [Date: NSMutableAttributedString]!
    static var fastFreeWeeks : [Date: NSMutableAttributedString]!
    static var movableFeasts : [Date: NSMutableAttributedString]!
    static var nonMovableFeasts : [Date: NSMutableAttributedString]!
    static var greatFeasts : [Date: NSMutableAttributedString]!

    static func makeTitle(title: String, fontSize: CGFloat = 18.0) -> NSMutableAttributedString {
        let centerStyle = NSMutableParagraphStyle()
        centerStyle.alignment = .center
        
        let attributes: [String : Any] = [convertFromNSAttributedStringKey(NSAttributedString.Key.paragraphStyle): centerStyle,
                                          convertFromNSAttributedStringKey(NSAttributedString.Key.font): UIFont.boldSystemFont(ofSize: fontSize),
                                          convertFromNSAttributedStringKey(NSAttributedString.Key.foregroundColor): textFontColor
        ]
        
        return NSMutableAttributedString(string: title, attributes:convertToOptionalNSAttributedStringKeyDictionary(attributes))
    }

    static func makeFeastStr(code: NameOfDay, color: UIColor? = nil) -> NSMutableAttributedString  {
        let dateStr = formatter1.string(from: Cal.d(code)).capitalizingFirstLetter()
        let feastStr = Translate.s(Cal.codeFeastDescr[code]!.1)
        
        var cal : NSMutableAttributedString? = nil
        cal = cal + ("\(dateStr) — \(feastStr)\n\n", color ?? textFontColor)
        
        cal!.addAttribute(NSAttributedString.Key.font,
                          value: UIFont.systemFont(ofSize: textFontSize),
                          range: NSMakeRange(0, cal!.length))
        
        return cal!
    }
    
    static func makeLentStr(fromDate: Date, toDate: Date, descr : String) -> NSMutableAttributedString  {
        let d1 = formatter2.string(from: fromDate)
        let d2 = formatter2.string(from: toDate)
        
        var cal : NSMutableAttributedString? = nil
        cal = cal + ("С \(d1) по \(d2) — \(descr)\n\n", textFontColor)
        
        cal!.addAttribute(NSAttributedString.Key.font,
                          value: UIFont.systemFont(ofSize: textFontSize),
                          range: NSMakeRange(0, cal!.length))
        
        return cal!
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
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
