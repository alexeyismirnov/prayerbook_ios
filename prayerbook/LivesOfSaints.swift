//
//  LivesOfSaints.swift
//  ponomar
//
//  Created by Alexey Smirnov on 26/1/2024.
//  Copyright © 2024 Alexey Smirnov. All rights reserved.
//

import Foundation
import SQLite
import swift_toolkit

private class SaintsCalendar {
    let t_content = Table("content")
    let f_text = Expression<String>("text")
    
    var year: Int
    var days = [ChurchDay]()
    var db: Connection
    
    public func day(_ name: String) -> ChurchDay {
        days.filter() { $0.id == name }.first!
    }
    
    init(_ db: Connection, _ year: Int) {
        self.db = db
        self.year = year
        
        let decoder = JSONDecoder()
        decoder.userInfo = [.year: year]
                
        days = try! db.prepareRowIterator(t_content)
            .map { try! decoder.decode(ChurchDay.self, from: $0[f_text].data(using: .utf8)!) }
        
        let pascha = Cal.paschaDay(year)
        let pentecost = pascha + 49.days
        let greatLentStart = pascha - 48.days
        
        day("holyFathersSixCouncils").date = Cal.nearestSunday(Date(29, 7, year))
        
        day("greatMonday").date = pascha - 6.days
        day("greatTuesday").date = pascha - 5.days
        day("greatWednesday").date = pascha - 4.days
        day("greatSaturday").date = pascha - 1.days
        
        day("beginningOfGreatLent").date = greatLentStart
        day("saturday1GreatLent").date = greatLentStart + 5.days
        day("sunday1GreatLent").date = greatLentStart + 6.days
        day("sunday3GreatLent").date = greatLentStart + 20.days
        day("sunday5GreatLent").date = greatLentStart + 34.days
        day("palmSunday").date = pascha - 7.days

        day("ascension").date = pascha + 39.days
        day("pentecost").date = pentecost
        day("sunday1AfterPentecost").date = pentecost + 7.days

        day("sunday3AfterPascha").date = pascha + 14.days
        day("sunday7AfterPascha").date = pascha + 42.days
        
        let nativity = Date(7, 1, year)
        let nativityWeekday = DayOfWeek(date: nativity)
        
        if nativityWeekday == .sunday {
            day("josephBetrothed").date = nativity + 1.days

        } else {
            day("josephBetrothed").date = Cal.nearestSundayAfter(nativity)  
        }

    }
}

class LivesOfSaintsModel : EbookModel {
    private var calendars = [Int:SaintsCalendar]()
    
    init() {
        super.init("augustin_en")
    }
    
    func forDate(_ date: Date) -> [Preachment] {
        let year = DateComponents(date: date).year!
       
        if calendars[year] == nil {
           calendars[year] = SaintsCalendar(db, year)
        }
        
        if let d = calendars[year]!.days.filter({ $0.date == date }).first {
            let pos = BookPosition(model: self, data: d.reading!.replacingOccurrences(of: ".epub", with: ""))
            return [Preachment(position: pos, title: d.comment!, subtitle: "Lives of saints")]

        }

        return []
    }
    
}
