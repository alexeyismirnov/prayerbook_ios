//
//  TaushevModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/20/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import SQLite

class TaushevModel : BookModel {
    let content = Table("content")
    let f_id = Expression<String>("id")
    let f_subtitle = Expression<String>("subtitle")
    let f_text = Expression<String>("text")

    var code: String = "Taushev"
    var title = ""
    var author: String?
    
    var contentType: BookContentType = .text
    var lang = Translate.language

    var hasChapters = false
    
    static let shared = TaushevModel()
    var db : Connection
    
    init() {
        let path = Bundle.main.path(forResource: "taushev", ofType: "sqlite")!
        db = try! Connection(path, readonly: true)
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
    
    func getData(_ id: String) -> [String:Any]? {
        let result = try! db.pluck(content.filter(f_id == id))
        
        if let r = result {
            return ["subtitle": r[f_subtitle], "text": r[f_text]]
        } else {
            return nil
        }
    }
    
    func getPreachment(_ date: Date) -> [Preachment] {
        var results = [Preachment]()
        let readings = ChurchReading.forDate(date)

        for r in readings {
            let str = r.components(separatedBy: "#")[0]
            let p = str.split { $0 == " " }.map { String($0) }
            
            for i in stride(from: 0, to: p.count-1, by: 2) {
                if ["John", "Luke", "Mark", "Matthew"].contains(p[i]) {
                    let id = Translate.readings(p[i] + " " + p[i+1])
                    
                    if let row = getData(id) {
                        results.append(Preachment(
                            position: BookPosition(model: TaushevModel.shared, data: row["text"] as! String),
                            title: row["subtitle"] as! String,
                            subtitle: "Архиеп. Аверкий (Таушев)"
                        ))
                    }
                    
                }
            }
        }
        
        return results

    }
    
}


