//
//  BibleModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 3/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

struct BibleModel {
    static func decorateLine(_ verse:Int64, _ content:String, _ fontSize:CGFloat) -> NSAttributedString {
        var text = NSAttributedString()
        text += "\(verse) ".colored(with: UIColor.red) + content.colored(with: Theme.textColor) + "\n"
        
        return text.systemFont(ofSize: fontSize)
    }
    
    static func getChapter(_ name: String, _ chapter: Int) -> NSAttributedString {
        var text = NSAttributedString()
        
        let prefs = UserDefaults(suiteName: groupId)!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        let header = (name == "ps") ? "Кафизма %@" : Translate.s("Chapter %@")
        let title = String(format: header, Translate.stringFromNumber(chapter))
            .colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered
        
        text += title + "\n\n"
        
        for line in Db.book(name, whereExpr: "chapter=\(chapter)") {
            let row  = decorateLine(line["verse"] as! Int64, line["text"] as! String, CGFloat(fontSize))
            text = text + row
        }
        
        return text
    }
    
}

class OldTestamentModel : BookModel {
    var code : String = "OldTestament"
    var title = "Ветхий Завет"
    var mode: BookType = .text

    var isExpandable = true
    var hasNavigation = true
    
    static let data: [[(String, String)]] = [
        [
            ("Genesis", "gen"),
            ("Exodus", "ex"),
            ("Leviticus","lev"),
            ("Numbers","num"),
            ("Deuteronomy","deut"),
            ],
        [
            ("Joshua","josh"),
            ("Judges","judg"),
            ("Ruth","ruth"),
            ("1 Samuel","1sam"),
            ("2 Samuel","2sam"),
            ("1 Kings","1kings"),
            ("2 Kings","2kings"),
            ("1 Chronicles","1chron"),
            ("2 Chronicles","2chron"),
            ("Ezra","ezra"),
            ("Nehemiah","neh"),
            ("Esther","esther"),
            ],
        [
            ("Job","job"),
            ("Psalms","ps"),
            ("Proverbs","prov"),
            ("Ecclesiastes","eccles"),
            ("Song of Solomon","song"),
            ],
        
        [
            ("Isaiah","isa"),
            ("Jeremiah","jer"),
            ("Lamentations","lam"),
            ("Ezekiel","ezek"),
            ("Daniel","dan"),
            ("Hosea","hos"),
            ("Joel","joel"),
            ("Amos","amos"),
            ("Obadiah","obad"),
            ("Jonah","jon"),
            ("Micah","mic"),
            ("Nahum","nahum"),
            ("Habakkuk","hab"),
            ("Zephaniah","zeph"),
            ("Haggai","hag"),
            ("Zechariah","zech"),
            ("Malachi","mal"),
            ]
    ]
    
    static let shared = OldTestamentModel()

    func getSections() -> [String] {
        return ["Пятикнижие Моисея", "Книги исторические", "Книги учительные", "Книги пророческие"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return OldTestamentModel.data[section].map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return Db.numberOfChapters(OldTestamentModel.data[index.section][index.row].1)
    }

    func getComment(commentId: Int) -> String? { return nil }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == "OldTestament" else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        let chapter = Int(comp[3])!
        
        var chapterTitle = "глава"
        
        if (OldTestamentModel.data[section][row].1 == "ps") {
            chapterTitle = "кафизма"
        }
        
        return "Ветхий Завет - " + Translate.s(OldTestamentModel.data[section][row].0) + ", \(chapterTitle) \(chapter+1)"
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }
        let code =  OldTestamentModel.data[index.section][index.row].1
        return BibleModel.getChapter(code, chapter+1)
    }
    
    func getBookmark(at pos: BookPosition) -> String {
        guard let index = pos.index, let chapter = pos.chapter else { return "" }
        return "OldTestament_\(index.section)_\(index.row)_\(chapter)"
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        let numChapters = Db.numberOfChapters(OldTestamentModel.data[index.section][index.row].1)
        if chapter < numChapters-1 {
            return BookPosition(index: index, chapter: chapter+1)
        } else {
            return nil
        }
        
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        if chapter > 0 {
            return BookPosition(index: index, chapter: chapter-1)
        } else {
            return nil
        }
    }
}

class NewTestamentModel : BookModel {
    var code: String = "NewTestament"
    var title = "Новый Завет"

    var mode: BookType = .text

    var isExpandable = true
    var hasNavigation = true

    static let data: [[(String, String)]] = [
        [
            ("Gospel of St Matthew", "matthew"),
            ("Gospel of St Mark", "mark"),
            ("Gospel of St Luke", "luke"),
            ("Gospel of St John", "john"),
            ("Acts of the Apostles", "acts"),
            ],
        [
            ("General Epistle of James", "james"),
            ("1st Epistle General of Peter", "1pet"),
            ("2nd General Epistle of Peter", "2pet"),
            ("1st Epistle General of John", "1john"),
            ("2nd Epistle General of John", "2john"),
            ("3rd Epistle General of John", "3john"),
            ("General Epistle of Jude", "jude"),
            ],
        [
            ("Epistle of St Paul to Romans", "rom"),
            ("1st Epistle of St Paul to Corinthians", "1cor"),
            ("2nd Epistle of St Paul to Corinthians", "2cor"),
            ("Epistle of St Paul to Galatians", "gal"),
            ("Epistle of St Paul to Ephesians", "ephes"),
            ("Epistle of St Paul to Philippians", "phil"),
            ("Epistle of St Paul to Colossians", "col"),
            ("1st Epistle of St Paul Thessalonians", "1thess"),
            ("2nd Epistle of St Paul Thessalonians", "2thess"),
            ("1st Epistle of St Paul to Timothy", "1tim"),
            ("2nd Epistle of St Paul to Timothy", "2tim"),
            ("Epistle of St Paul to Titus", "tit"),
            ("Epistle of St Paul to Philemon", "philem"),
            ("Epistle of St Paul to Hebrews", "heb"),
            ],
        [
            ("Revelation of St John the Devine", "rev")
        ]
    ]
    
    static let shared = NewTestamentModel()
    
    func getSections() -> [String] {
        return ["Евангелия и Деяния", "Соборные Послания", "Послания св. Апостола Павла", "Откровение св. Ап. Иоанна Богослова"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return NewTestamentModel.data[section].map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return Db.numberOfChapters(NewTestamentModel.data[index.section][index.row].1)
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == "NewTestament" else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        let chapter = Int(comp[3])!
        
        return "Новый Завет - " + Translate.s(NewTestamentModel.data[section][row].0) + ", глава \(chapter+1)"
    }
        
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        let code =  NewTestamentModel.data[index.section][index.row].1
        return BibleModel.getChapter(code, chapter+1)
    }
    
    func getBookmark(at pos: BookPosition) -> String {
        guard let index = pos.index, let chapter = pos.chapter else { return "" }
        return "NewTestament_\(index.section)_\(index.row)_\(chapter)"
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        let numChapters = Db.numberOfChapters(NewTestamentModel.data[index.section][index.row].1)
        if chapter < numChapters-1 {
            return BookPosition(index: index, chapter: chapter+1)
        } else {
            return nil
        }
        
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index, let chapter = pos.chapter else { return nil }

        if chapter > 0 {
            return BookPosition(index: index, chapter: chapter-1)
        } else {
            return nil
        }
    }
}

