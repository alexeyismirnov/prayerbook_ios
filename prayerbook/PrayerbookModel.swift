//
//  PrayerbookModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/6/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

protocol BasicModel  {
    var data: [[String]] { get }
    var basename : String { get }
}

extension BasicModel where Self: BookModel {
    func getSections() -> [String] { return [""] }
    
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
        
        let filename = String(format: "%@_%d_%@.html", basename, index.row, Translate.language)
        let bundleName = Bundle.main.path(forResource: filename, ofType: nil)
        let txt:String! = try? String(contentsOfFile: bundleName!, encoding: String.Encoding.utf8)
        
        return txt
    }
    
    func getBookmark(at pos: BookPosition) -> String? { return nil }
    func getBookmarkName(_ bookmark: String) -> String { return "" }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? { return nil }
    func getPrevSection(at pos: BookPosition) -> BookPosition? { return nil }
}

class EucharistModel : BasicModel, BookModel {
    var code: String = "Eucharist"
    var basename: String = "prayer_communion"
    
    var mode: BookType = .html
    var isExpandable = false

    var hasDate = false
    var date: Date = Date()
    
    var title: String {
        get { return Translate.s("Eucharist prayers") }
    }
    
    var data: [[String]] = [
        ["A Canon of Repentance to our Lord Jesus Christ",
         "Canon To the Most Holy Mother of God",
         "Canon To the Guardian Angel",
         "Order of Pre-communion prayers",
         "Thanksgiving after Holy Communion"
        ]]

    static let shared = EucharistModel()
}

class PrayerbookModel : BasicModel, BookModel {
    var code: String = "Prayerbook"
    var basename: String = "prayer_book"
    
    var mode: BookType = .html
    var isExpandable = false

    var hasDate = false
    var date: Date = Date()
    
    var title: String {
        get { return Translate.s("Prayerbook") }
    }
    
    var data: [[String]] = [
        ["Morning Prayers",
         "Prayers before Sleep",
         "Prayers during the day",
         "The order of reading Canons and Akathists when alone",
         "Canon To our Lord Jesus Christ",
         "Akathist to our Sweetest Lord Jesus Christ"
        ]]
    
    static let shared = PrayerbookModel()
}


