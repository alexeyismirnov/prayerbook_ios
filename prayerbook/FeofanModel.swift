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

class FeofanModel : BookModel, PreachmentModel {
    var code: String = "Feofan"
    var title = ""
    var author: String?
    
    var contentType: BookContentType = .text
    var lang = Translate.language

    var hasChapters = false
    
    static let shared = FeofanModel()
    var db : Database
    
    init() {
        let path = Bundle.main.path(forResource: "feofan", ofType: "sqlite")!
        db = try! Database(path:path)
    }

    func getFeofan(_ id: String) -> String? {
        let results = try! db.selectFrom("thoughts", whereExpr:"id=\"\(id)\"") { ["id": $0["id"] , "descr": $0["descr"]] }
        
        if let res = results[safe: 0] {
            return res["descr"] as? String
        }
        
        return nil
    }
    
    func getFeofanGospel(_ id: String) -> String? {
        let results = try! db.prepareStatement("SELECT id,descr FROM thoughts WHERE id LIKE'%\(id)' AND fuzzy=1")
        
        while try! results.next() {
            let descr = results[1] as! String
            return descr
        }
        
        return nil
    }
    
    func getPreachment(_ date: Date) -> [Preachment] {
        let cal = Cal.fromDate(date)
        let title = "Мысли на каждый день"
    
        var results = [Preachment]()

        if date == cal.d("meetingOfLord") {
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("33")!),
                title: title)]
        }
        
        switch date {
        case Date(21,9, date.year),
             Date(14,10, date.year):
            return []
            
        case Date(4,12, date.year):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("325")!),
                title: title)]
            
        case Date(19,8, date.year):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("218")!),
                title: title)]
            
        case cal.greatLentStart-3.days:
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("36")!),
                title: title)]
            
        case cal.greatLentStart-5.days:
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("34")!),
                title: title)]
            
        case cal.pascha-3.days,
            cal.pascha-2.days:
            return []
            
        case cal.d("sundayOfForefathers"):
            return [Preachment(
                position: BookPosition(model: FeofanModel.shared, data: getFeofan("346")!),
                title: title)]
            
        case cal.greatLentStart ..< cal.pascha:
            let num = (cal.greatLentStart >> date) + 39
            
            if let f = getFeofan("\(num)") {
                return [Preachment(
                    position: BookPosition(model: FeofanModel.shared, data: f),
                    title: title)]
            }
            
        default:
            let readings = ChurchReading.forDate(date)
            
            for r in readings {
                let str = r.components(separatedBy: "#")[0]
                
                let pericope = Translate.readings(str)
                let id = pericope.replacingOccurrences(of: " ", with: "")
                
                if let f = getFeofan(id) {
                    results.append(Preachment(
                        position: BookPosition(model: FeofanModel.shared, data: f),
                        title: title,
                        subtitle: pericope
                    ))
                }
            }
            
            if results.count == 0 {
                for r in readings {
                    let str = r.components(separatedBy: "#")[0]
                    let p = str.split { $0 == " " }.map { String($0) }
                    
                    for i in stride(from: 0, to: p.count-1, by: 2) {
                        if ["John", "Luke", "Mark", "Matthew"].contains(p[i]) {
                            let pericope = Translate.readings(p[i] + " " + p[i+1])
                            let id = pericope.replacingOccurrences(of: " ", with: "")
                            
                            if let f = getFeofanGospel(id) {
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
                results[0].subtitle = ""
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
        
        return content.colored(with: Theme.textColor).font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
}

