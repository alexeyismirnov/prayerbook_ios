//
//  Db.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import Foundation
import UIKit
import Squeal

struct Db {
    static func saints(date: NSDate) -> [[String:Bindable?]] {
        let dc = NSDateComponents(date: date)
        let filename = String(format: "saints_%02d_%@", dc.month, Translate.language)
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "sqlite")!
        let db = try! Database(path:path)
        
        return try! db.selectFrom("saints", whereExpr:"day=\(dc.day)", orderBy: "-typikon") { ["name": $0["name"], "typikon": $0["typikon"]] }
    }
    
    static func book(name: String, whereExpr: String = "") -> [[String:Bindable?]] {
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString+"_"+Translate.language, ofType: "sqlite")!
        let db = try! Database(path:path)
        return try! db.selectFrom("scripture", whereExpr:whereExpr) { ["verse": $0["verse"], "text": $0["text"]] }
    }
    
    static func numberOfChapters(name: String) -> Int {
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString+"_"+Translate.language, ofType: "sqlite")!
        let db = try! Database(path:path)
        
        let results = try! db.prepareStatement("SELECT COUNT(DISTINCT chapter) FROM scripture")
        
        while try! results.next() {
            let num = results[0] as! Int64
            return Int(num)
        }

        return 0
    }
}
