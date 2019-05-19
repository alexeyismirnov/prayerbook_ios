//
//  BookModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Foundation

enum BookType {
    case text, html
}

struct BookPosition {
    init(model: BookModel, index: IndexPath, chapter: Int) {
        self.model = model
        self.index = index
        self.chapter = chapter
    }
    
    init(index: IndexPath, chapter: Int) {
        self.index = index
        self.chapter = chapter
    }
    
    init(location: String) {
        self.location = location
    }
    
    var model : BookModel?
    var index : IndexPath?
    var chapter : Int?
    var location: String?
}

protocol BookModel {
    var code : String { get }
    var mode : BookType { get }
    
    func getTitle() -> String
    func getSections() -> [String]
    func getItems(_ section : Int) -> [String]
    
    func isExpandable() -> Bool
    func getNumChapters(_ index : IndexPath) -> Int
    func getComment(commentId: Int) -> String?
    
    func getContent(at pos: BookPosition) -> Any?
    func getBookmark(at pos: BookPosition) -> String
    
    func getNextSection(at pos: BookPosition) -> BookPosition?
    func getPrevSection(at pos: BookPosition) -> BookPosition?
    
    func getBookmarkName(_ bookmark : String) -> String
}

