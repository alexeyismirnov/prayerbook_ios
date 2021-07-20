//
//  EbookModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 7/13/21.
//  Copyright © 2021 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class EbookModel : BookModel {
    var code: String
    var title: String
    var contentType: BookContentType
    
    var hasChapters = false
    var hasDate = false
    var date: Date = Date()
    
    var db : Database
    
    lazy var sections: [String] = {
        return try! db.selectAll("SELECT title FROM sections ORDER BY id") { $0.stringValueAtIndex(0) ?? "" }
    }()
    
    var items = [Int:[String]]()

    init(_ filename: String) {
        let path = Bundle.main.path(forResource: filename, ofType: "sqlite")!
        db = try! Database(path:path)
        
        code = try! db.selectString("SELECT value FROM data WHERE key=$0", parameters: ["code"])!
        title = try! db.selectString("SELECT value FROM data WHERE key=$0", parameters: ["title"])!
        contentType = BookContentType(rawValue:
                                        try! db.selectInt("SELECT value FROM data WHERE key=$0", parameters: ["contentType"])!)!

    }
    
    func getSections() -> [String] {
        return sections
    }
    
    func getItems(_ section: Int) -> [String] {
        if items[section] != nil { return items[section]! }
        
        items[section] =
            try! db.selectAll("SELECT title FROM content WHERE section=$0 ORDER BY item", parameters: [section])
                { $0.stringValueAtIndex(0) ?? "" }
        
        return items[section]!
    }
    
    func getTitle(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }

        return try! db.selectString("SELECT title FROM content WHERE section=$0 AND item=$1",
                             parameters: [index.section, index.row])!
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return try! db.selectString("SELECT text FROM comments WHERE id=$0", parameters: [commentId])!
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }

        var text =  try! db.selectString("SELECT text FROM content WHERE section=$0 AND item=$1",
                                         parameters: [index.section, index.row])!
        
        if (contentType == .text) {
            let fontSize = CGFloat(AppGroup.prefs.integer(forKey: "fontSize"))
            return  NSAttributedString(string: text).font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
            
        } else {
            let pattern = "comment_(\\d+)"
            let regex = try! NSRegularExpression(pattern: pattern)
            
            if regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).count > 0 {
                let text2 = NSMutableString(string: text)
                
                regex.replaceMatches(in: text2, options: .reportProgress, range: NSRange(location: 0,length: text2.length), withTemplate: "&nbsp;&nbsp;<a href=\"comment://$1\"><img class=\"icon\"/></a>&nbsp;&nbsp;")
                
                text = String(text2)
            }
            
            return text
        }
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }

        let items = getItems(index.section)
        
        if index.row+1 == items.count {
            if index.section+1 == sections.count {
                return nil
            } else {
                return BookPosition(index: IndexPath(row: 0, section: index.section+1))
            }
        } else {
            return BookPosition(index: IndexPath(row: index.row+1, section: index.section))
        }
        
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }

        if index.row == 0 {
            if index.section == 0 {
                return nil
            } else {
                let items = getItems(index.section-1)
                return BookPosition(index: IndexPath(row: items.count-1, section: index.section-1))
            }
        } else {
            return BookPosition(index: IndexPath(row: index.row-1, section: index.section))
        }
    }
    
    func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }
        return "\(code)_\(index.section)_\(index.row)"
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        
        let sectionTitle = getTitle(at: BookPosition(index: IndexPath(row: row, section: section)))!
        
        return "\(title) - \(sectionTitle)"
    }
}

