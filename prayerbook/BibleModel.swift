//
//  BibleModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 3/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit
import Squeal

struct BibleModel {
    static func book(_ name: String, whereExpr: String = "") -> [[String:Bindable?]] {
        let path = Bundle.main.path(forResource: name.lowercased()+"_"+Translate.language, ofType: "sqlite")!
        let db = try! Database(path:path)
        
        return try! db.selectFrom("scripture", whereExpr:whereExpr) { ["verse": $0["verse"], "text": $0["text"]] }
    }
    
    static func numberOfChapters(_ name: String) -> Int {
        let path = Bundle.main.path(forResource: name.lowercased()+"_"+Translate.language, ofType: "sqlite")!
        let db = try! Database(path:path)
        
        let results = try! db.prepareStatement("SELECT COUNT(DISTINCT chapter) FROM scripture")
        
        while try! results.next() {
            let num = results[0] as! Int64
            return Int(num)
        }
        
        return 0
    }
    
    static func decorateLine(_ verse:Int64, _ content:String, _ fontSize:CGFloat, _ isPsalm: Bool = false) -> NSAttributedString {
        if isPsalm {
            let text = NSMutableAttributedString(attributedString: content.colored(with: Theme.textColor).systemFont(ofSize: fontSize))
            
            if let r = content.range(of: Translate.s("Statis"), options:[], range: nil) {
                text.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.bold), range: NSRange(r, in: content))
            }
            
            if Translate.language == "en" ||  Translate.language == "ru" {
                if let r = content.range(of: ".", options:[], range: nil) {
                    let r2 = content.startIndex..<r.upperBound
                    
                    text.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(r2, in: content))
                }
            }

            return "\(verse) ".colored(with: UIColor.red).systemFont(ofSize: fontSize) + text + "\n"
        }
        
        var text = NSAttributedString()
        text += "\(verse) ".colored(with: UIColor.red) + content.colored(with: Theme.textColor) + "\n"
        
        return text.systemFont(ofSize: fontSize)
    }
    
    static func getChapter(_ name: String, _ chapter: Int) -> NSAttributedString {
        var text = NSAttributedString()
        
        let prefs = AppGroup.prefs!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        let header = (name == "ps") ? Translate.s("Kathisma %@") : Translate.s("Chapter %@")
        let title = String(format: header, Translate.stringFromNumber(chapter))
            .colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered
        
        text += title + "\n\n"
        
        for line in book(name, whereExpr: "chapter=\(chapter)") {
            let row  = decorateLine(line["verse"] as! Int64, line["text"] as! String, CGFloat(fontSize), name == "ps")
            text = text + row
        }
        
        return text
    }
    
}

class OldTestamentModel : BookModel {
    var code : String = "OldTestament"
    var title = Translate.s("Old Testament")
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
        return ["Five Books of Moses", "Historical books", "Wisdom books", "Prophets books"].map { return Translate.s($0) }
    }
    
    func getItems(_ section: Int) -> [String] {
        return OldTestamentModel.data[section].map { return Translate.s($0.0) }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return BibleModel.numberOfChapters(OldTestamentModel.data[index.section][index.row].1)
    }

    func getComment(commentId: Int) -> String? { return nil }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == "OldTestament" else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        let chapter = Int(comp[3])!
        
        let header = (OldTestamentModel.data[section][row].1 == "ps") ? Translate.s("Kathisma %@") : Translate.s("Chapter %@")
        let chapterTitle = String(format: header, Translate.stringFromNumber(chapter+1)).lowercased()
        
        return "\(title) - " + Translate.s(OldTestamentModel.data[section][row].0) + ", \(chapterTitle)"
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

        let numChapters = BibleModel.numberOfChapters(OldTestamentModel.data[index.section][index.row].1)
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
    var title = Translate.s("New Testament")

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
        return ["Four Gospels and Acts", "Catholic Epistles", "Epistles of Paul", "Apocalypse"].map { return Translate.s($0) }
    }
    
    func getItems(_ section: Int) -> [String] {
        return NewTestamentModel.data[section].map { return  Translate.s($0.0) }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return BibleModel.numberOfChapters(NewTestamentModel.data[index.section][index.row].1)
    }
    
    func getComment(commentId: Int) -> String? { return nil }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == "NewTestament" else { return "" }
        
        let section = Int(comp[1])!
        let row = Int(comp[2])!
        let chapter = Int(comp[3])!
        
        let chapterTitle = String(format: Translate.s("Chapter %@"), Translate.stringFromNumber(chapter+1)).lowercased()
        
        return "\(title) - " + Translate.s(NewTestamentModel.data[section][row].0) + ", \(chapterTitle)"
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

        let numChapters = BibleModel.numberOfChapters(NewTestamentModel.data[index.section][index.row].1)
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

