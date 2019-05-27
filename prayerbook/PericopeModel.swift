//
//  PericopeModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class PericopeModel : BookModel {
    var code : String = "Pericope"
    var title = ""
    var mode: BookType = .text
    
    var isExpandable = false
    var hasNavigation = false
    
    func getPericope(_ str: String, decorated: Bool = true) -> [(NSAttributedString, NSAttributedString)] {
        var result = [(NSAttributedString, NSAttributedString)]()
        let prefs = UserDefaults(suiteName: groupId)!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        
        var pericope = str.split { $0 == " " }.map { String($0) }
        
        for i in stride(from: 0, to: pericope.count-1, by: 2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercased()
            let bookTuple = (NewTestamentModel.data+OldTestamentModel.data).flatMap { $0.filter { $0.1 == fileName } }
            
            var bookName = NSAttributedString()
            var text = NSAttributedString()
            
            if decorated {
                bookName = (Translate.s(bookTuple[0].0) + " " + pericope[i+1]).colored(with: Theme.textColor).boldFont(ofSize: fontSize).centered
                
            } else {
                bookName = NSAttributedString(string: Translate.s(bookTuple[0].0))
            }
            
            let arr2 = pericope[i+1].components(separatedBy: ",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                let arr3 = segment.components(separatedBy: "-")
                for offset in arr3 {
                    var arr4 = offset.components(separatedBy: ":")
                    
                    if arr4.count == 1 {
                        range += [ (chapter, Int(arr4[0])!) ]
                        
                    } else {
                        chapter = Int(arr4[0])!
                        range += [ (chapter, Int(arr4[1])!) ]
                    }
                }
                
                if range.count == 1 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse=\(range[0].1)") {
                        if decorated {
                            text += BibleModel.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize )
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                } else if range[0].0 != range[1].0 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1)") {
                        if decorated {
                            text += BibleModel.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                    for chap in range[0].0+1 ..< range[1].0 {
                        for line in Db.book(fileName, whereExpr: "chapter=\(chap)") {
                            if decorated {
                                text += BibleModel.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                            } else {
                                text += (line["text"] as! String) + " "
                            }
                        }
                    }
                    
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[1].0) AND verse<=\(range[1].1)") {
                        if decorated {
                            text += BibleModel.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                } else {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1) AND verse<=\(range[1].1)") {
                        if decorated {
                            text += BibleModel.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                }
            }
            
            text += "\n"
            result += [(bookName, text)]
        }
        
        return result
    }
    
    static let shared = PericopeModel()
    
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
        guard let str = pos.location else { return nil }
        let pericope = getPericope(str.trimmingCharacters(in: CharacterSet.whitespaces))
        
        var text = NSAttributedString()
        
        for (title, content) in pericope {
            text +=  title + "\n\n" + content + "\n"
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

