//
//  EucharistModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/5/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//


import UIKit
import Squeal
import swift_toolkit

class EucharistModel : BookModel {
    var code: String = "Eucharist"
    
    var title: String {
        get { return Translate.s("Eucharist prayers") }
    }
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasNavigation = false
        
    func getSections() -> [String] { return [""] }
    
    var data: [[String]] = [
        ["A Canon of Repentance to our Lord Jesus Christ",
         "Canon To the Most Holy Mother of God",
         "Canon To the Guardian Angel",
         "Order of Pre-communion prayers",
         "Thanksgiving after Holy Communion"
        ]]
    
    static let shared = EucharistModel()
    
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
        
        let filename = String(format: "prayer_communion_%d_%@.html", index.row, Translate.language)
        let bundleName = Bundle.main.path(forResource: filename, ofType: nil)
        let txt:String! = try? String(contentsOfFile: bundleName!, encoding: String.Encoding.utf8)
        
        return txt
    }

    func getBookmark(at pos: BookPosition) -> String { return "" }
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? { return nil }
    func getPrevSection(at pos: BookPosition) -> BookPosition? { return nil }
}

