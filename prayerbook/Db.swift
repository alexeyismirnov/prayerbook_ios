//
//  Db.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import Foundation

import UIKit

struct Db {
    static func saints(date: NSDate) -> StepSequence {
        var error: NSError?
        let dc = NSDateComponents(date: date)

        let filename = String(format: "saints_%02d_%@", dc.month, Translate.language)
        
        let path = NSBundle.mainBundle().pathForResource(filename, ofType: "sqlite")!
        let db = Database(path:path, error:&error)
        
        return db!.selectFrom("saints", whereExpr:"day=\(dc.day)", orderBy: "-typikon", error:&error)
    }
    
    static func book(name: String, whereExpr: String = "") -> StepSequence {
        var error: NSError?
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString+"_"+Translate.language, ofType: "sqlite")!
        let db = Database(path:path, error:&error)
        return db!.selectFrom("scripture", whereExpr:whereExpr, error:&error)
    }
    
    static func numberOfChapters(name: String) -> Int {
        var error: NSError?
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString+"_"+Translate.language, ofType: "sqlite")!
        let db = Database(path:path, error:&error)
        
        for row in db!.query("SELECT COUNT(DISTINCT chapter) FROM scripture", error:&error) {
            let num = row![0] as! Int64
            return Int(num)
        }
        
        return 0
    }
}
