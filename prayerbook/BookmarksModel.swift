//
//  BookmarksModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/12/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

class BookmarksModel : BookModel {
    var code: String = "Bookmarks"
    
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
    
    func getVC(index: IndexPath, chapter: Int) -> UIViewController {
        let bookmarks = prefs.stringArray(forKey: "bookmarks")!
        let b = bookmarks[index.row]
        let comp = b.components(separatedBy: "_")

        let model = books.filter() { $0.1.code == comp[0] }.first!.1
        
        let index = IndexPath(row: Int(comp[2])!, section: Int(comp[1])!)
        let chapter : Int = (comp.count == 4) ? Int(comp[3])! : 0

        return model.getVC(index: index, chapter: chapter)
    }
    
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
}

