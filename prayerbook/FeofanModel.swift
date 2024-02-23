//
//  FeofanModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import SQLite

class FeofanModel : BookModel {
    let thoughts = Table("thoughts")
    let f_id = Expression<String>("id")
    let f_descr = Expression<String>("descr")
    let f_fuzzy = Expression<Int>("fuzzy")

    var code: String = "Feofan"
    var title = ""
    var author: String?
    
    var contentType: BookContentType = .text
    var lang = Translate.language

    var hasChapters = false
    
    static let shared = FeofanModel()
    var db : Connection
    
    init() {
        let path = Bundle.main.path(forResource: "feofan_en", ofType: "sqlite")!
        db = try! Connection(path, readonly: true)
    }

    func getFeofan(_ id: String) -> String? {
        return try! db.pluck(thoughts.filter(f_id == id))?[f_descr]
    }
    
    func getFeofanGospel(_ id: String) -> String? {
        return try! db.pluck(thoughts.filter(f_id.like("%\(id)") && f_fuzzy == 1))?[f_descr]
    }
    
    func getPreachment(_ date: Date) -> [Preachment] {
        let cal = Cal.fromDate(date)
        let title = "Thoughts for Each Day"

        var results = [Preachment]()

        if date == cal.d("meetingOfLord") {
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("33")!),
                title: title, subtitle: "St. Theophan the Recluse")]
        }
        
        switch date {
        case Date(21,9, date.year),
             Date(14,10, date.year):
            return []
            
        case Date(4,12, date.year):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("325")!),
                title: title, subtitle: "St. Theophan the Recluse")]
            
        case Date(19,8, date.year):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("218")!),
                title: title, subtitle: "St. Theophan the Recluse")]
            
        case cal.greatLentStart-3.days:
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("36")!),
                title: title, subtitle: "St. Theophan the Recluse")]
            
        case cal.greatLentStart-5.days:
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("34")!),
                title: title, subtitle: "St. Theophan the Recluse")]
            
        case cal.pascha-3.days,
            cal.pascha-2.days:
            return []
            
        case cal.d("sundayBeforeNativity1"),
            cal.d("sundayBeforeNativity2"):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("346")!),
                title: title, subtitle: "St. Theophan the Recluse")]
            
        case cal.greatLentStart ..< cal.pascha:
            let num = (cal.greatLentStart >> date) + 39
            
            if let f = getFeofan("\(num)") {
                return [Preachment(
                    position: BookPosition(model: FeofanModel.shared, data: f),
                    title: title, subtitle: "St. Theophan the Recluse")]
            }
            
        default:
            let readings = ChurchReading.forDate(date)
            
            for r in readings {
                let str = r.components(separatedBy: "#")[0].trim()
                                
                if let f = getFeofan(str) {
                    results.append(Preachment(
                        position: BookPosition(model: FeofanModel.shared, data: f),
                        title: title,
                        subtitle: str
                    ))
                }
            }
            
            if results.count == 0 {
                for r in readings {
                    let str = r.components(separatedBy: "#")[0]
                    let p = str.split { $0 == " " }.map { String($0) }
                    
                    for i in stride(from: 0, to: p.count-1, by: 2) {
                        if ["John", "Luke", "Mark", "Matthew"].contains(p[i]) {
                            let pericope = p[i] + " " + p[i+1]
                            
                            if let f = getFeofanGospel(pericope) {
                                results.append(Preachment(
                                    position: BookPosition(model: FeofanModel.shared, data: f),
                                    title: title,
                                    subtitle: pericope
                                ))
                            }
                        }
                    }
                }
            }
            
            if results.count == 1 {
                results[0].subtitle = "St. Theophan the Recluse"
            }
        }
        
        return results
    }
    
    func getSections() -> [String] { return [] }
    
    func getItems(_ section: Int) -> [String] { return [] }
    
    func getNumChapters(_ index: IndexPath) -> Int { return 0 }
    
    func getContent(at pos: BookPosition) -> Any? {
        let prefs = AppGroup.prefs!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        let content = NSAttributedString(string: pos.data as! String)
        
        return content.colored(with: Theme.textColor).systemFont(ofSize: CGFloat(fontSize))
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
}

