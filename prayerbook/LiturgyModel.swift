//
//  LiturgyModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class LiturgyModel : BookModel {
    var code: String = "Liturgy"
    
    var title: String {
        get { return Translate.s("The Divine Liturgy of St John Chrysostom") }
    }
    
    var shortTitle: String {
        get { return Translate.s("Divine Liturgy") }
    }
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasDate = false
    var date: Date = Date()
    
    var db : Database
    
    func getSections() -> [String] {
        return ["The Liturgy of the Catechumens", "The Liturgy of the Faithful"].map { return Translate.s($0) }
    }
    
    var data: [[String]] = [
        [
            "First Exclamations",
            "The Litany of Peace",
            "The Prayer of the First Antiphon",
            "The First Antiphone",
            "Little Litany",
            "The Prayer of the Second Antiphon",
            "The Second Antiphon",
            "Little Litany",
            "The Prayer of the Third Antiphon",
            "The Third Antiphone",
            "Prayer of the Little Entrance",
            "Prayer of the Thrice-Holy",
            "The Thrice-Holy (Trisagion)",
            "The Epistle",
            "The Gospel",
            "The Litany of Fervent Supplication",
            "The Prayer of the Litany of Fervent Supplication",
            "The Litany for the Departed",
            "Prayer for the Departed",
            "The Litany of the Catechumens",
            "The Prayer for the Catechumens",
        ],
        [
            "Litany",
            "The First Prayer of the Faithful",
            "The Second Prayer of the Faithful",
            "The Cherubic Hymn and the Great Entry",
            "Litany",
            "The Symbol of Faith",
            "The Anaphora",
            "Litany before the Lord's Prayer",
            "The Lord's Prayer",
            "The Communion of the People",
            "Litany",
            "The Prayer behind the Ambo",
            "Psalm 33",
            "The Dismissal"
        ]
    ]
    
    static let shared = LiturgyModel()
    
    init() {
        let path = Bundle.main.path(forResource: "liturgy_"+Translate.language, ofType: "sqlite")!
        db = try! Database(path:path)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .themeChangedNotification, object: nil)
    }
    
    @objc func reload() {
        let path = Bundle.main.path(forResource: "liturgy_"+Translate.language, ofType: "sqlite")!
        db = try! Database(path:path)
    }
    
    func getItems(_ section: Int) -> [String] {
        return data[section].map { return Translate.s($0) }
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
        let section = (index.section == 0) ? index.row+1 : data[0].count + index.row+1
        
        let liturgyDB = try! db.selectFrom("content", whereExpr:"section=\(section)", orderBy: "row")
        { ["text": $0["text"], "row": $0["row"]] }

        for line in liturgyDB {
            res += line["text"] as! String
        }
        
        let title = "<p align=\"center\"><b>" + Translate.s(data[index.section][index.row]) + "</b></p>"
        
        return title + res
    }
    
    func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return "" }
        return "\(code)_\(index.section)_\(index.row)"
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        return "\(shortTitle) - " + Translate.s(data[Int(comp[1])!][Int(comp[2])!])
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }
        
        if (index.section == 1 && index.row == data[1].count-1) {
            return nil
        } else if (index.section == 0 && index.row == data[0].count-1) {
            return BookPosition(index: IndexPath(row: 0, section: 1), chapter: 0)
        } else {
            return BookPosition(index: IndexPath(row: index.row+1, section: index.section), chapter: 0)
        }
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }
        
        if (index.section == 0 && index.row == 0) {
            return nil
        } else if (index.section == 1 && index.row == 0) {
            return BookPosition(index: IndexPath(row: data[0].count-1, section: 0), chapter: 0)
        } else {
            return BookPosition(index: IndexPath(row: index.row-1, section: index.section), chapter: 0)
        }
    }
    
}

