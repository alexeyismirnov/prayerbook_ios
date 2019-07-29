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

class TroparionModel : BookModel {
    var code = "Troparion"
    
    var mode:BookType = .text
    
    var title = ""
    
    var isExpandable = false
    
    var hasNavigation = false
    
    static let shared = TroparionModel()
    
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
    
    static func troparionData(_ date: Date) -> [(String, String)] {
        var troparion = [(String,String)]()

        let dc = DateComponents(date: date)
        
        let path = Bundle.main.path(forResource: "troparion", ofType: "sqlite")!
        let db = try! Database(path:path)
        
        let day = dc.day!
        let month = dc.month!
        
        let results = try! db.selectFrom("tropari", whereExpr:"month=\(month) AND day=\(day)") { ["title": $0["title"] , "glas": $0["glas"], "content": $0["content"] ] }
        
        for line in results {
            var title = line["title"] as! String
            let glas = line["glas"] as! String
            let content = line["content"] as! String
            
            if glas.count > 0 {
                title = title + ", " + glas
            }
            
            troparion.append((title,content))
        }
        
        return troparion
    }
    
    static func getTroparion(for date: Date) -> [(String, String)] {
        var troparion = [(String,String)]()
        
        Cal.setDate(date)
        
        if (Cal.isLeapYear) {
            switch date {
            case Cal.leapStart ..< Cal.leapEnd:
                troparion = troparionData(date+1.days)
                break
                
            case Cal.leapEnd:
                troparion = troparionData(Date(29, 2, Cal.currentYear))
                break
                
            default:
                troparion = troparionData(date)
            }
            
        } else {
            troparion = troparionData(date)
            if (date == Cal.leapEnd) {
                troparion += troparionData(Date(29, 2, 2000))
            }
        }
        
        return troparion
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let data : [(String,String)] = pos.data as? [(String, String)]  else { return nil }
      
        var text = NSAttributedString()
        
        let prefs = AppGroup.prefs!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        for line in data {
            let title = line.0
            let content = line.1
            
            text += title.colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered + "\n\n"
            text += content.colored(with: Theme.textColor).systemFont(ofSize: CGFloat(fontSize)) + "\n\n"
        }
        
        return text
    }
    
    func getBookmark(at pos: BookPosition) -> String {
        return ""
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        return nil
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        return nil
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        return ""
    }
    
}

