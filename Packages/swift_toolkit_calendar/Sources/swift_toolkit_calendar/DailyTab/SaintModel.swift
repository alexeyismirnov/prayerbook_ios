//
//  SaintModel.swift
//  swift-toolkit
//
//  Created by Alexey Smirnov on 7/29/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//


import class Foundation.Bundle
import struct Foundation.Date
import struct Foundation.DateComponents

import SQLite

public struct SaintModel {
    static var databases = [String: Connection]()
    
    static let saints = Table("saints")
    static let day = SQLite.Expression<Int>("day")
    static let typikon = SQLite.Expression<Int>("typikon")
    static let name = SQLite.Expression<String>("name")

    static public func saints(_ date: Date) -> [Saint] {
        var saints = [Saint]()
        let cal = Cal.fromDate(date)
        
        if (cal.isLeapYear) {
            switch date {
            case cal.leapStart ..< cal.leapEnd:
                saints = saintsData(date+1.days)
                break
                
            case cal.leapEnd:
                saints = saintsData(Date(29, 2, cal.year))
                break
                
            default:
                saints = saintsData(date)
            }
            
        } else {
            saints = saintsData(date)
            if (date == cal.leapEnd) {
                saints += saintsData(Date(29, 2, 2000))
            }
        }
        
        return saints
    }
    
    static func getDatabase(_ filename: String) -> Connection {
        let url = AppGroup.url.appendingPathComponent(filename)
        let db = try! Connection(url.path, readonly: true)

        databases[filename] = db
        return db
    }
    
    private static func saintsData(_ date: Date) -> [Saint] {
        var results = [Saint]()
        
        let dc = DateComponents(date: date)

        let filename = String(format: "saints_%02d_%@.sqlite", dc.month!, Translate.language)
        let db = databases[filename] ?? getDatabase(filename)
        
        results.append(
            contentsOf: try! db.prepareRowIterator(saints
                .filter(day == dc.day!)
                .order(typikon.desc))
            .map { Saint($0[name], FeastType(rawValue: $0[typikon])!) }
        )
        
        return results
    }
    
}
