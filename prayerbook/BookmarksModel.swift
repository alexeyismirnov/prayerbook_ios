//
//  BookmarksModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/12/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

struct BookPosition {
    init(model: BookModel, index: IndexPath, chapter: Int) {
        self.model = model
        self.index = index
        self.chapter = chapter
    }
    
    var model : BookModel
    var index : IndexPath
    var chapter : Int
}

class BookmarksModel : BookModel {
    var code = "Bookmarks"
    var mode: BookType = .text
    
    let prefs = UserDefaults(suiteName: groupId)!
    static let shared = BookmarksModel()

    func getTitle() -> String { return "Закладки" }
    
    func getSections() -> [String] {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        return (bookmarks.count == 0) ? [String]() : [""]
    }
    
    func getItems(_ section: Int) -> [String] {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        
        var arr = [String]()
        
        for b in bookmarks {
            let comp = b.components(separatedBy: "_")
            let model = books.filter() { $0.1.code == comp[0] }.first!.1
            
            arr.append(model.getBookmarkName(b))
        }

        return arr
    }
    
    func isExpandable() -> Bool { return false }
    
    func getNumChapters(_ index: IndexPath) -> Int { return 0 }
    
    func getComment(commentId: Int) -> String? { return nil }
    
    func resolveBookmarkAt(row: Int) -> BookPosition {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        let comp = bookmarks[row].components(separatedBy: "_")
        
        let model = books.filter() { $0.1.code == comp[0] }.first!.1
        let index = IndexPath(row: Int(comp[2])!, section: Int(comp[1])!)
        let chapter : Int = (comp.count == 4) ? Int(comp[3])! : 0
        
        return BookPosition(model: model, index: index, chapter: chapter)
    }
    
    func getContent(index: IndexPath, chapter: Int) -> Any? { return nil }
        
    func getBookmark(index: IndexPath, chapter: Int) -> String { return "" }
    
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
    func getNextSection(index: IndexPath, chapter: Int) -> (IndexPath, Int)? { return nil }
    
    func getPrevSection(index: IndexPath, chapter: Int) -> (IndexPath, Int)? { return nil }
    
}

