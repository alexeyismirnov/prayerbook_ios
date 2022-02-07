//
//  TroparionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class SaintTropariaModel : BookModel {
    var code = "Troparion"
    var lang = Translate.language

    var contentType: BookContentType = .text
    
    var title = ""
    var author: String?

    var hasChapters = false
    var db : Database
    
    init() {
        let path = Bundle.main.path(forResource: "troparion", ofType: "sqlite")!
        db = try! Database(path:path)
    }

    static let shared = SaintTropariaModel()
    
    func getSections() -> [String] {
        return []
    }
    
    func getItems(_ section: Int) -> [String] {
        return []
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func troparionData(_ date: Date) -> [Troparion] {
        var troparion = [Troparion]()

        let dc = DateComponents(date: date)
        
        let day = dc.day!
        let month = dc.month!
        
        let results = try! db.selectFrom("tropari", whereExpr:"month=\(month) AND day=\(day)")
            { ["title": $0["title"] , "glas": $0["glas"], "content": $0["content"] ] }
        
        for line in results {
            var title = line["title"] as! String
            let glas = line["glas"] as! String
            let content = line["content"] as! String
            
            if glas.count > 0 {
                title = title + ", " + glas
            }
            
            troparion.append(Troparion(title: title, content: content))
        }
        
        return troparion
    }
    
    func getTroparion(_ date: Date) -> [Troparion] {
        var troparion = [Troparion]()
        
        let cal = Cal2.fromDate(date)
                
        if (cal.isLeapYear) {
            switch date {
            case cal.leapStart ..< cal.leapEnd:
                troparion = troparionData(date+1.days)
                break
                
            case cal.leapEnd:
                troparion = troparionData(Date(29, 2, cal.year))
                break
                
            default:
                troparion = troparionData(date)
            }
            
        } else {
            troparion = troparionData(date)
            if (date == cal.leapEnd) {
                troparion += troparionData(Date(29, 2, 2000))
            }
        }
        
        return troparion
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let data : [Troparion] = pos.data as? [Troparion]  else { return nil }
      
        var text = NSAttributedString()
        let prefs = AppGroup.prefs!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        for line in data {
            text += line.title.colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered + "\n\n"
            text += line.content.colored(with: Theme.textColor).systemFont(ofSize: CGFloat(fontSize)) + "\n\n"
        }
        
        return text
    }
    
}

