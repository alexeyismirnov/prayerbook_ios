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
    let f_text = SQLite.Expression<String>("text")
    
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
        let isLeapYear = Cal.isLeap(year: year)
        let pentecost = pascha + 49.days
        let greatLentStart = pascha - 48.days
        
        day("holyFathersSixCouncils").date = Cal.nearestSunday(Date(29, 7, year))
        day("holyFathersSeventhCouncil").date = Cal.nearestSunday(Date(24, 10, year))
        day("findingOfHead").date = isLeapYear ? Date(8, 3, year) : Date(9, 3, year)
        
        day("saturdayOfFathers").date =  greatLentStart - 2.days
        day("sunday4GreatLent").date =  greatLentStart + 27.days

        day("greatMonday").date = pascha - 6.days
        day("greatTuesday").date = pascha - 5.days
        // day("greatWednesday").date = pascha - 4.days
        day("greatSaturday").date = pascha - 1.days

        day("ascension").date = pascha + 39.days
        day("pentecost").date = pentecost
        day("sunday1AfterPentecost").date = pentecost + 7.days

        day("sunday3AfterPascha").date = pascha + 14.days
        day("sunday4AfterPascha").date = pascha + 21.days
        day("sunday7AfterPascha").date = pascha + 42.days
        
        day("kurskTheotokos").date = pentecost+12.days

        let nativity = Date(7, 1, year)
        let nativityWeekday = DayOfWeek(date: nativity)
        
        /*
        if nativityWeekday == .sunday {
            day("josephBetrothed").date = nativity + 1.days

        } else {
            day("josephBetrothed").date = Cal.nearestSundayAfter(nativity)
        }
         */

    }
}

class LivesOfSaintsModel : EbookModel {
    private var calendars = [Int:SaintsCalendar]()
    static let shared = LivesOfSaintsModel()

    init() {
        super.init("augustin")
    }
    
    func getPreachment(_ date: Date) -> [Preachment] {
        let year = DateComponents(date: date).year!
        var res = [Preachment]()
        
        if calendars[year] == nil {
           calendars[year] = SaintsCalendar(db, year)
        }
        
        for d in calendars[year]!.days.filter({ $0.date == date }) {
            let pos = BookPosition(model: self, data: d.reading!.replacingOccurrences(of: ".epub", with: ""))
            res.append(Preachment(position: pos, title: d.comment!, subtitle: Translate.s("Lives of saints")))
        }

        return res
    }
    
}
