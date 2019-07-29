//
//  Db.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import Foundation
import Squeal
import swift_toolkit

struct Db {
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
    
    static func feofan(_ id: String) -> String? {
        let path = Bundle.main.path(forResource: "feofan", ofType: "sqlite")!
        let db = try! Database(path:path)

        let results = try! db.selectFrom("thoughts", whereExpr:"id=\"\(id)\"") { ["id": $0["id"] , "descr": $0["descr"]] }
        
        if let res = results[safe: 0] {
            return res["descr"] as? String
        }
        
        return nil
    }
    
    static func feofanGospel(_ id: String) -> String? {
        let path = Bundle.main.path(forResource: "feofan", ofType: "sqlite")!
        let db = try! Database(path:path)

        let results = try! db.prepareStatement("SELECT id,descr FROM thoughts WHERE id LIKE'%\(id)' AND fuzzy=1")
        
        while try! results.next() {
            let descr = results[1] as! String
            return descr
        }
        
        return nil
    }
    
}
