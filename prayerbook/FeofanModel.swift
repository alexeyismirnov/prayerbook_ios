//
//  FeofanModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import Squeal

class FeofanModel : BookModel {
    var code: String = "Feofan"
    var title = ""
    var contentType: BookContentType = .text
    var lang = Translate.language

    var hasChapters = false
    var hasDate = false
    var date: Date = Date()
    
    static let shared = FeofanModel()

    static func feofanDB(_ id: String) -> String? {
        let path = Bundle.main.path(forResource: "feofan", ofType: "sqlite")!
        let db = try! Database(path:path)

        let results = try! db.selectFrom("thoughts", whereExpr:"id=\"\(id)\"") { ["id": $0["id"] , "descr": $0["descr"]] }
        
        if let res = results[safe: 0] {
            return res["descr"] as? String
        }
        
        return nil
    }
    
    static func feofanGospel(_ id: String) -> String? {
        let path = Bundle.main.path(forResource: "feofan", ofType: "sqlite")!
        let db = try! Database(path:path)

        let results = try! db.prepareStatement("SELECT id,descr FROM thoughts WHERE id LIKE'%\(id)' AND fuzzy=1")
        
        while try! results.next() {
            let descr = results[1] as! String
            return descr
        }
        
        return nil
    }
    
    static func getFeofan(for date: Date) -> [(String, String)] {
        var feofan = [(String,String)]()
        
        let pascha = Cal.d(.pascha)
        let greatLentStart = pascha-48.days
        
        if date == Cal.d(.meetingOfLord) {
            feofan.append(("", feofanDB("33")!))
            return feofan
        }
        
        switch date {
        case Date(21,9, date.year),
             Date(14,10, date.year):
            return []
            
        case Date(4,12, date.year):
            feofan.append(("", feofanDB("325")!))
            
        case Date(19,8, date.year):
            feofan.append(("", feofanDB("218")!))
            
        case greatLentStart-3.days:
            feofan.append(("", feofanDB("36")!))
            
        case greatLentStart-5.days:
            feofan.append(("", feofanDB("34")!))
            
        case pascha-3.days,
             pascha-2.days:
            return []
            
        case Cal.d(.sundayOfForefathers):
            feofan.append(("", feofanDB("346")!))
            
        case greatLentStart..<pascha:
            let num = (greatLentStart >> date) + 39
            
            if let f = feofanDB("\(num)") {
                feofan.append(("",f))
            }
            
        default:
            let readings = DailyReading.getDailyReading(date)
            
            for r in readings {
                let str = r.components(separatedBy: "#")[0]
                
                let pericope = Translate.readings(str)
                let id = pericope.replacingOccurrences(of: " ", with: "")
                
                if let f = feofanDB(id) {
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
                            
                            if let f = feofanGospel(id) {
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
        let prefs = AppGroup.prefs!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        let content = NSAttributedString(string: pos.location!)
        
        return content.colored(with: Theme.textColor).font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
}

