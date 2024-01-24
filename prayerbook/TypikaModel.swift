//
//  TypikaModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/10/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite
import swift_toolkit

class TypikaModel : ServiceModel {
    let t_content = Table("content")
    let t_data = Table("data")
    let t_fragments = Table("fragments")
    let t_prokimen = Table("prokimen")
    
    let f_id = Expression<Int>("id")
    let f_section = Expression<Int>("section")
    let f_glas = Expression<Int>("glas")
    
    let f_title = Expression<String>("title")
    let f_text = Expression<String>("text")
    let f_key = Expression<String>("key")
    let f_value = Expression<String>("value")

    var lang : String

    var code: String = "Typika"
    var author: String?

    var title: String
    
    var contentType: BookContentType = .html

    var hasChapters = false
    var hasDate = true
    
    var cal: Cal!

    var tone: Int!
    var fragments = [String]()
    var prokimen = [String]()

    var date: Date = Date() {
        didSet {
            cal = Cal.fromDate(date)
            tone = cal.getTone(date)!
                       
            fragments = [String]()
            prokimen = [String]()
            
            fragments.append(
                contentsOf: try! db.prepareRowIterator(t_fragments
                    .filter(f_glas == tone!)
                    .order(f_id.asc))
                .map { $0[f_text]}
            )
            
            prokimen.append(
                contentsOf: try! db.prepareRowIterator(t_prokimen
                    .filter(f_glas == tone!)
                    .order(f_id.asc))
                .map { $0[f_text]}
            )
            
            prokimen.append(contentsOf: prokimen[0].components(separatedBy: "/"))
            prokimen[0] = prokimen[0].replacingOccurrences(of: "/", with: " ")

        }
    }
    
    var db : Connection
    
    func getSections() -> [String] { return [""] }

    lazy var data: [String] = {
        try! db.prepareRowIterator(t_content
            .order(f_section.asc))
        .map { $0[f_title] }
    }()
    
    init(_ lang: String) {
        self.lang = lang

        let path = Bundle.main.path(forResource: "typika_\(lang)", ofType: "sqlite")!
        db = try! Connection(path, readonly: true)
        
        title = try! db.pluck(t_data.filter(f_key == "title"))![f_value]
    }
        
    func getItems(_ section: Int) -> [String] {
        return data
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getTitle(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }
        return data[index.row]
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        var content = ""
        var results = [String]()
        
        results.append(
            contentsOf: try! db.prepareRowIterator(t_content
                .filter(f_section == index.row+1))
            .map { $0[f_text]}
        )
        
        content = results.joined()
        content = content.replacingOccurrences(of: "GLAS", with: Translate.stringFromNumber(tone!))
        
        for (i, fragment) in fragments.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"FRAGMENT%d!", i+1),
                with: fragment)
        }
        
        for (i, text) in prokimen.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"PROKIMEN%d", i+1),
                with: text)
        }
        
        let readingStr = ChurchReading.forDate(date).last!
        let readings = PericopeModel(lang: lang).getPericope(readingStr, decorated: false)
        
        for (i, (title, text)) in readings.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"TITLE%d", (i+1)),
                with: title.string)
            
            content = content.replacingOccurrences(
                of: String(format:"READING%d", (i+1)),
                with: text.string)
            
        }
        
        // let title = "<p align=\"center\"><b>" + Translate.s(data[index.row]) + "</b></p>"
        
        return content
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        if let index = pos.index {
            if index.row < data.count - 1 {
                return BookPosition(index: IndexPath(row: index.row+1, section: 0), chapter: 0)
            }
        }
        return nil
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        if let index = pos.index {
            if index.row > 0 {
                return BookPosition(index: IndexPath(row: index.row-1, section: 0), chapter: 0)
            }
        }
        
        return nil
    }
    
    func dateIterator(startDate: Date) -> AnyIterator<Date> {
        var currentDate = startDate
        var nextDate, pascha: Date!
        
        return AnyIterator({
            repeat {
                nextDate = Cal.nearestSundayAfter(currentDate)
                pascha = Cal.paschaDay(nextDate.year)
                currentDate = nextDate + 1.days
                
            } while (pascha-48.days ... pascha ~= nextDate)
          
            
            return nextDate
        })
    }
    
}


