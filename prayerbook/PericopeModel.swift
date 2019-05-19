//
//  PericopeModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/19/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import Foundation

class PericopeModel : BookModel {
    var code : String = "Pericope"
    var mode: BookType = .text
    
    func getTitle() -> String {
        return ""
    }
    
    func getSections() -> [String] {
        return []
    }
    
    func getItems(_ section: Int) -> [String] {
        return []
    }
    
    func isExpandable() -> Bool {
        return false
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        return nil
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

