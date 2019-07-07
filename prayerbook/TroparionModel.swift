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
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        
        let path = Bundle.main.path(forResource: "troparion", ofType: "sqlite")!
        let db = try! Database(path:path)
        
        var text = NSAttributedString()
        
        let prefs = UserDefaults(suiteName: groupId)!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        let day = index.row
        let month = index.section
        
        let results = try! db.selectFrom("tropari", whereExpr:"month=\(month) AND day=\(day)") { ["title": $0["title"] , "glas": $0["glas"], "content": $0["content"] ] }

        for line in results {
            let title = line["title"] as! String
            let glas = line["glas"] as! String
            let content = line["content"] as! String
            
            text += (title + ", " + glas).colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered + "\n\n"
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

