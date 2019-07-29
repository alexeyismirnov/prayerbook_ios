//
//  TroparionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/9/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import Squeal
import swift_toolkit

struct Troparion {
    var title : String
    var content : String
    var url : String?
    
    init(title : String, content : String, url : String? = nil) {
        self.title = title
        self.content = content
        self.url = url
    }
}

struct TroparionFeastModel {
    static let documentDirectory:URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let path = documentDirectory.path + "/tropari/tropari/tropari.sqlite"

    static func getTroparion(_ code : NameOfDay) -> [Troparion]  {
        let db = try! Database(path:path)
        
        var troparion = [Troparion]()

        let results = try! db.selectFrom("tropari", whereExpr:"code=\(code.rawValue)", orderBy: "id") { ["title": $0["title"], "content": $0["content"], "url": $0["url"]]}
        
        for line in results {
            let title = line["title"] as! String
            let content =  line["content"] as! String
            let url = line["url"] as? String
            
            troparion.append(Troparion(title: title, content: content, url: url))
        }
        
        return troparion
    }
    
    static func troparionAvailable() -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
}
