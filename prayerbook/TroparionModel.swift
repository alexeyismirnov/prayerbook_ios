//
//  TroparionModel.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 26/11/2024.
//  Copyright © 2024 Alexey Smirnov. All rights reserved.
//

import Foundation
import SQLite
import swift_toolkit

fileprivate let tropari = Table("tropari")

struct Troparion {
    var title : String
    var content : String
    var glas: String?
    
    init(title : String, content : String, glas: String? = nil) {
        self.title = title
        self.content = content
        self.glas = glas
    }
}

class TroparionModel : BookModel {
    let f_day = SQLite.Expression<Int>("day")
    let f_month = SQLite.Expression<Int>("month")
    let f_title = SQLite.Expression<String>("title")
    let f_comment = SQLite.Expression<String>("comment")
    let f_content = SQLite.Expression<String>("content")
    
    var code = "Troparion"
    var lang = Translate.language

    var contentType: BookContentType = .text
    
    var title = ""
    var author: String?

    var hasChapters = false
    
    var db_saints, db_feasts : Connection
    var cal: Cal!
    
    init() {
        let path1 = Bundle.main.path(forResource: "troparion_en", ofType: "sqlite")!
        let path2 = Bundle.main.path(forResource: "troparion_feast_en", ofType: "sqlite")!

        db_saints = try! Connection(path1, readonly: true)
        db_feasts = try! Connection(path2, readonly: true)
    }

    static let shared = TroparionModel()
    
    func getSections() -> [String] {
        return []
    }
    
    func getItems(_ section: Int) -> [String] {
        return []
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let data : [Troparion] = pos.data as? [Troparion]  else { return nil }
      
        var text = NSAttributedString()
        let prefs = AppGroup.prefs!
        let fontSize = prefs.integer(forKey: "fontSize")
        
        for line in data {
            var title = line.title
            if let glas = line.glas {
               title = title + ", " + glas
            }
            
            text += title.colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered + "\n\n"
            text += line.content.colored(with: Theme.textColor).systemFont(ofSize: CGFloat(fontSize)) + "\n\n"
            text += "\n"
        }
        
        return text
    }
    
    func getDataSaints(_ date: Date) -> [Troparion] {
        var troparion = [Troparion]()
        
        let d = date - 13.days
        let dc = DateComponents(date: d)
        
        troparion.append(
            contentsOf: try! db_saints.prepareRowIterator(tropari
                .filter(f_day == dc.day! && f_month == dc.month!))
            .map {
                return Troparion(title: $0[f_title], content: $0[f_content], glas: $0[f_comment])
            }
        )
        
        if (!cal.isLeapYear && date == cal.leapEnd) {
            troparion.append(
                contentsOf: try! db_saints.prepareRowIterator(tropari
                    .filter(f_day == 29 && f_month == 2))
                .map {
                    return Troparion(title: $0[f_title], content: $0[f_content], glas: $0[f_comment])
                }
            )
        }
        
        return troparion
    }
    
    func getDataFeast(_ id: String) -> [Troparion] {
        return try! db_feasts.prepareRowIterator(tropari
            .filter(f_comment == id))
        .map {
            return Troparion(title: $0[f_title], content: $0[f_content])
        }
    }
    
    func fetchSunday(_ date: Date) -> [Troparion] {
        if DayOfWeek(date: date) == .sunday {
          if let tone = cal.getTone(date) {
              return getDataFeast("sundayGlas\(tone)")
          }
        }
        return []
    }
    
    func fetchFeast(_ date: Date) -> [Troparion] {
        var results = [Troparion]()

        let feastsCodes = [
              "sundayOfPublicianAndPharisee",
              "sundayOfProdigalSon",
              "sundayOfDreadJudgement",
              "cheesefareSunday",
              "sunday1GreatLent",
              "sunday2GreatLent",
              "sunday3GreatLent",
              "sunday4GreatLent",
              "sunday5GreatLent",
              "sunday2AfterPascha",
              "sunday3AfterPascha",
              "sunday4AfterPascha",
              "sunday5AfterPascha",
              "sunday6AfterPascha",
              "sunday7AfterPascha",
              "sunday1AfterPentecost",
              "holyFathersSixCouncils",
              "holyFathersSeventhCouncil",
              "eveOfTheophany",
              "eveOfNativityOfGod",
              "saturday1GreatLent",
              "saturday2GreatLent",
              "saturday3GreatLent",
              "saturday4GreatLent",
              "saturday5GreatLent",
              "greatMonday",
              "greatTuesday",
              "greatWednesday",
              "greatThursday",
              "greatFriday",
              "greatSaturday"
            ]
        
        let descr = cal.getDayDescription(date).map { $0.id }
                
        for feast in Set(feastsCodes).intersection(Set(descr)) {
            results.append(contentsOf: getDataFeast(feast))
        }
        
        return results
    }
    
    func getTroparion(_ date: Date) -> [Troparion] {
        cal = Cal.fromDate(date)
        
        let greatFeasts = Cal.getGreatFeast(date).map { $0.id }
        var troparion = [Troparion]()
        
        if greatFeasts.count > 0 {
            for feast in greatFeasts {
                troparion.append(contentsOf: getDataFeast(feast))
                
                let otherGreatFeasts = [
                            "veilOfTheotokos",
                            "nativityOfJohn",
                            "beheadingOfJohn",
                            "peterAndPaul",
                            "dormition",
                            "nativityOfTheotokos",
                            "annunciation",
                            "entryIntoTemple"
                          ]
                if otherGreatFeasts.contains(feast) && DayOfWeek(date: date) == .sunday {
                    troparion.append(contentsOf: fetchSunday(date))
                    troparion.append(contentsOf: fetchFeast(date))
                }
            }
        
        } else {
            troparion.append(contentsOf: fetchSunday(date))
            troparion.append(contentsOf: fetchFeast(date))
            troparion.append(contentsOf: getDataSaints(date))
        }

        return troparion
    }
}
