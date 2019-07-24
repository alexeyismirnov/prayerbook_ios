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

var groupId = "group.rlc.ponomar-ru"

struct Db {
    static let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)!

    static func saints(_ date: Date) -> [(FeastType, String)] {
        var saints = [(FeastType, String)]()

        Cal.setDate(date)
        
        if (Cal.isLeapYear) {
            switch date {
            case Cal.leapStart ..< Cal.leapEnd:
                saints = Db.saintsData(date+1.days)
                break
                
            case Cal.leapEnd:
                saints = Db.saintsData(Date(29, 2, Cal.currentYear))
                break
                
            default:
                saints = Db.saintsData(date)
            }
            
        } else {
            saints = Db.saintsData(date)
            if (date == Cal.leapEnd) {
                saints += Db.saintsData(Date(29, 2, 2000))
            }
        }
        
        return saints
    }
    
    static func saintsData(_ date: Date) -> [(FeastType, String)] {
        let dc = DateComponents(date: date)
        let filename = String(format: "saints_%02d_%@.sqlite", dc.month!, Translate.language)
        
        let dst = groupURL.appendingPathComponent(filename)
        let db = try! Database(path:dst.path)
        
        var saints = [(FeastType, String)]()
        let saintsDB = try! db.selectFrom("saints", whereExpr:"day=\(dc.day!)", orderBy: "-typikon") { ["name": $0["name"], "typikon": $0["typikon"]] }
        
        for line in saintsDB {
            let name = line["name"] as! String
            let typikon = FeastType(rawValue: Int(line["typikon"] as! Int64))
            saints.append((typikon!, name))
        }

        return saints
    }
    
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
