//
//  TypikaModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/10/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class TypikaModel : BookModel {
    var code: String = "Typika"
    
    var title: String {
        get { return Translate.s("Typika Reader Service") }
    }
    
    var shortTitle: String {
        get { return Translate.s("Typika") }
    }
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasDate = true
    var date: Date = Date()
    
    var db : Database
    
    func getSections() -> [String] { return [""] }

    var data: [String] =
        [
            "First Exclamations",
            "The First Antiphone",
            "The Second Antiphon",
            "The Third Antiphone",
            "The Thrice-Holy (Trisagion)",
            "The Epistle",
            "The Gospel",
            "The Symbol of Faith",
            "The Lord's Prayer",
            "Kontakia",
            "Psalm 33",
            "The Dismissal"
    ]
    
    static let shared = TypikaModel()
    
    init() {
        let path = Bundle.main.path(forResource: "typika_"+Translate.language, ofType: "sqlite")!
        db = try! Database(path:path)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .themeChangedNotification, object: nil)
    }
    
    @objc func reload() {
        let path = Bundle.main.path(forResource: "typika_"+Translate.language, ofType: "sqlite")!
        db = try! Database(path:path)
    }
    
    func getItems(_ section: Int) -> [String] {
        return data.map { return Translate.s($0) }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        var res = ""
        let typika = try! db.selectFrom("content", whereExpr:"section=\(index.row+1)") { ["text": $0["text"]] }
        
        for line in typika {
            res += line["text"] as! String
        }
        
        let title = "<p align=\"center\"><b>" + Translate.s(data[index.row]) + "</b></p>"
        
        return title + res
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        if let index = pos.index {
            if index.row < data.count - 1 {
                return BookPosition(index: IndexPath(row: index.row+1, section: 0), chapter: 0)
            }
        }
        return nil
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        if let index = pos.index {
            if index.row > 0 {
                return BookPosition(index: IndexPath(row: index.row-1, section: 0), chapter: 0)
            }
        }
        
        return nil
    }
    
    func getBookmark(at pos: BookPosition) -> String? { return nil }
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
}

