//
//  SaintIcons.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/5/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import Foundation
import Squeal
import swift_toolkit

struct Saint {
    var id : Int
    var name : String
    var has_icon : Bool
    var day : Int
    var month : Int
    
    init(id: Int, name: String, has_icon: Bool, day: Int = 0, month: Int = 0) {
        self.id = id
        self.name = name
        self.has_icon = has_icon
        self.day = day
        self.month = month
    }
}


struct SaintIconModel {

    static let db = try! Database(path:Bundle.main.path(forResource: "icons", ofType: "sqlite")!)

    static func addSaints(date: Date) -> [Saint] {
        var saints = [Saint]()
        
        let day = date.day
        let month = date.month
        
        let results = try! db.selectFrom("app_saint", whereExpr:"month=\(month) AND day=\(day) AND has_icon=1")
        { ["id": $0["id"] , "name": $0["name"], "has_icon": $0["has_icon"]] }
        
        for data in results {
            let id = Int(exactly: data["id"] as! Int64) ?? 0
            let has_icon = data["has_icon"] as! Int64 == 0 ? false : true
            let saint = Saint(id: id, name: data["name"] as! String, has_icon: has_icon)
            saints.append(saint)
        }
        
        let links = try! db.selectFrom("app_saint JOIN link_saint",
                                       columns: ["link_saint.name AS name", "app_saint.id AS id", "app_saint.has_icon AS has_icon"],
                                       whereExpr: "link_saint.month=\(month) AND link_saint.day=\(day) AND app_saint.id = link_saint.id AND app_saint.has_icon=1") { ["id": $0["id"],  "name": $0["name"], "has_icon": $0["has_icon"] ]}
        
        for data in links {
            let id = Int(exactly: data["id"] as! Int64) ?? 0
            let has_icon = data["has_icon"] as! Int64 == 0 ? false : true
            let saint = Saint(id: id, name: data["name"] as! String, has_icon: has_icon)
            saints.append(saint)
        }
        
        return saints
    }
    
    static func get(_ date: Date) -> [Saint] {
        var saints = [Saint]()
        let year = date.year

        if let codes = Cal.moveableIcons[date] {
            for code in codes {
                let results = try! db.selectFrom("app_saint", whereExpr:"id=\(code.rawValue)")
                { [ "name": $0["name"], "has_icon": $0["has_icon"]] }
                
                for data in results {
                    let has_icon = data["has_icon"] as! Int64 == 0 ? false : true
                    let saint = Saint(id: code.rawValue, name: data["name"] as! String, has_icon: has_icon)
                    saints.append(saint)
                }
            }
        }
        
        let isLeapYear = (year % 400) == 0 || ((year%4 == 0) && (year%100 != 0))
        let leapStart = Date(29, 2, year)
        let leapEnd = Date(13, 3, year)
        
        if isLeapYear {
            switch date {
            case leapStart ..< leapEnd:
                saints += addSaints(date: date+1.days)
                break
                
            case leapEnd:
                saints += addSaints(date: Date(29, 2, year))
                break
                
            default:
                saints += addSaints(date: date)
            }
        } else {
            saints += addSaints(date: date)
            
            if date == leapEnd {
                saints += addSaints(date: Date(29, 2, 2000))
            }
        }
        
        return saints

    }
    
}

