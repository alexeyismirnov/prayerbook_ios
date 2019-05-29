//
//  FeofanModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class FeofanModel : BookModel {
    var code: String = "Feofan"
    var title = ""
    var mode: BookType = .text
    
    var isExpandable = false
    var hasNavigation = false
    
    static let shared = FeofanModel()

    static func getFeofan(for date: Date) -> [(String, String)] {
        var feofan = [(String,String)]()
        
        let pascha = Cal.paschaDay(date.year)
        let greatLentStart = pascha-48.days
        
        if date == Cal.d(.meetingOfLord) {
            feofan.append(("", Db.feofan("33")!))
            return feofan
        }
        
        switch date {
        case Date(21,9, date.year),
             Date(14,10, date.year):
            return []
            
        case Date(4,12, date.year):
            feofan.append(("", Db.feofan("325")!))
            
        case Date(19,8, date.year):
            feofan.append(("", Db.feofan("218")!))
            
        case greatLentStart-3.days:
            feofan.append(("", Db.feofan("36")!))
            
        case greatLentStart-5.days:
            feofan.append(("", Db.feofan("34")!))
            
        case pascha-3.days,
             pascha-2.days:
            return []
            
        case Cal.d(.sundayOfForefathers):
            feofan.append(("", Db.feofan("346")!))
            
        case greatLentStart..<pascha:
            let num = (greatLentStart >> date) + 39
            
            if let f = Db.feofan("\(num)") {
                feofan.append(("",f))
            }
            
        default:
            let readings = DailyReading.getDailyReading(date)
            
            for r in readings {
                let str = r.components(separatedBy: "#")[0]
                
                let pericope = Translate.readings(str)
                let id = pericope.replacingOccurrences(of: " ", with: "")
                
                if let f = Db.feofan(id) {
                    feofan.append((pericope,f))
                    
                }
            }
            
            if  feofan.count == 0 {
                for r in readings {
                    let str = r.components(separatedBy: "#")[0]
                    let p = str.split { $0 == " " }.map { String($0) }
                    
                    for i in stride(from: 0, to: p.count-1, by: 2) {
                        if ["John", "Luke", "Mark", "Matthew"].contains(p[i]) {
                            let pericope = Translate.readings(p[i] + " " + p[i+1])
                            let id = pericope.replacingOccurrences(of: " ", with: "")
                            
                            if let f = Db.feofanGospel(id) {
                                feofan.append((pericope,f))
                            }
                        }
                    }
                }
            }
        }
        
        return feofan
    }
    
    func getSections() -> [String] { return [] }
    
    func getItems(_ section: Int) -> [String] { return [] }
    
    func getNumChapters(_ index: IndexPath) -> Int { return 0 }
    
    func getContent(at pos: BookPosition) -> Any? {
        let prefs = UserDefaults(suiteName: groupId)!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        let content = NSAttributedString(string: pos.location!)
        
        return content.colored(with: Theme.textColor).font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? { return nil }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? { return nil }
    
    func getBookmark(at pos: BookPosition) -> String { return "" }
    
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
}

