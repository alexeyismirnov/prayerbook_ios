//
//  Db.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
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

}
