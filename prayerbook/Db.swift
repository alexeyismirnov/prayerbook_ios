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
    static let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupId)!

    static func saints(date: NSDate) -> [(FeastType, String)] {
        var saintsDB = [[String:Bindable?]]()
        var saints = [(FeastType, String)]()

        Cal.setDate(date)
        let isLeapYear = (Cal.currentYear % 400) == 0 || ((Cal.currentYear%4 == 0) && (Cal.currentYear%100 != 0))
        
        if (isLeapYear) {
            let leapStart = NSDate(29, 2, Cal.currentYear)
            let leapEnd = NSDate(13, 3, Cal.currentYear)
            
            switch date {
            case leapStart ..< leapEnd:
                saintsDB = Db.saintsData(date+1.days)
                break
                
            case leapEnd:
                saintsDB = Db.saintsData(NSDate(29, 2, Cal.currentYear))
                break
                
            default:
                saintsDB = Db.saintsData(date)
            }
            
        } else {
            saintsDB = Db.saintsData(date)
            if (date == NSDate(13, 3, Cal.currentYear)) {
                saintsDB += Db.saintsData(NSDate(29, 2, 2000))
            }
        }
        
        for line in saintsDB {
            let name = line["name"] as! String
            let typikon = FeastType(rawValue: Int(line["typikon"] as! Int64))
            saints.append((typikon!, name))
        }

        return saints
    }
    
    static func saintsData(date: NSDate) -> [[String:Bindable?]] {
        let dc = NSDateComponents(date: date)
        let filename = String(format: "saints_%02d_%@.sqlite", dc.month, Translate.language)
        let dst = groupURL.URLByAppendingPathComponent(filename)
        let db = try! Database(path:dst.path!)
        
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
