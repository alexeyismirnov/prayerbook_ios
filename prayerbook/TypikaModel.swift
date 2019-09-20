//
//  TypikaModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 9/10/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class TypikaModel : BookModel {
    var code: String = "Typika"
    
    var title: String {
        get { return Translate.s("Typika Reader Service") }
    }
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasDate = true
    
    var tone: Int!
    var fragments = [String]()
    
    var date: Date = Date() {
        didSet {
            tone = Cal.getTone(date)!

            fragments = [String]()
            
            let res = try! db.selectFrom("fragments", whereExpr:"glas=\(tone!)", orderBy: "id") { ["text": $0["text"]] }
            for line in res {
                fragments.append(line["text"] as! String)
            }
        }
    }
    
    var db : Database
    
    func getSections() -> [String] { return [""] }

    var data: [String] =
        [
            "Начинательные возгласы",
            "Первый антифон",
            "Второй антифон",
            "Третий антифон, Блаженны",
            "Тропарь и Трисвятое",
            "Чтение Апостола",
            "Чтение Евангелия",
            "Символ веры",
            "Молитва Господня",
            "Кондаки",
            "Псалом 33",
            "Отпуст"
    ]
    
    var bookTitle: [String:String] = [
        "Евангелие от Матфея": "От Матфея Святаго Евангелия",
        "Евангелие от Марка": "От Марка Святаго Евангелия",
        "Евангелие от Луки": "От Луки Святаго Евангелия",
        "Евангелие от Иоанна": "От Иоанна Святаго Евангелия",
        "Деяния святых апостолов": "Деяний святых апостол",
        "Послание к Римлянам": "К римляном послания святаго Апостола Павла",
        "послание к Коринфянам": "К коринфяном послания святаго Апостола Павла",
        "Послание к Галатам": " К галатом послания святаго Апостола Павла",
        "Послание к Ефесянам": "Ко ефесеем послания святаго Апостола Павла",
        "Послание к Филиппийцам": "К филипписием послания святаго Апостола Павла",
        "Послание к Колоссянам": "К колоссаем послания святаго Апостола Павла",
        "послание к Фессалоникийцам": "К солуняном послания святаго Апостола Павла",
        "послание к Тимофею": "К Тимофею послания святаго Апостола Павла",
        "Послание к Титу": "К Титу послания святаго Апостола Павла",
        "Послание к Филимону": "К Филимону послания святаго Апостола Павла",
        "Послание к Евреям": "Ко евреем послания святаго Апостола Павла",
        "Послание Иакова": "Соборного послания Иаковля",
        "послание Петра": "Соборного послания Петрова",
        "послание Иоанна": "Соборного послания Иоаннова",
        "Послание Иуды": "Соборного послания Иудина"]
    
    static let shared = TypikaModel()
    
    init() {
        let path = Bundle.main.path(forResource: "typika", ofType: "sqlite")!
        db = try! Database(path:path)
    }
    
    func getItems(_ section: Int) -> [String] {
        return data.map { return Translate.s($0) }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        var content = ""
        let typika = try! db.selectFrom("content", whereExpr:"section=\(index.row+1)") { ["text": $0["text"]] }
        
        for line in typika {
            content += line["text"] as! String
        }
        
        content = content.replacingOccurrences(of: "GLAS", with: Translate.stringFromNumber(tone!))
        
        for (i, fragment) in fragments.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"FRAGMENT%d!", i+1),
                with: fragment)
        }
        
        let readingStr = DailyReading.getRegularReading(date)!
        let readings = PericopeModel.shared.getPericope(readingStr, decorated: false)
        
        for (i, (title, text)) in readings.enumerated() {
            let regex = try! NSRegularExpression(pattern:"\\d-..", options: .caseInsensitive)
            var titleStr = title.string
            
            titleStr = regex.stringByReplacingMatches(
                in: titleStr,
                options: [],
                range: NSRange(titleStr.startIndex..., in: titleStr),
                withTemplate: "")

            content = content.replacingOccurrences(
                of: String(format:"TITLE%d", (i+1)),
                with: bookTitle[titleStr] ?? "")
            
            content = content.replacingOccurrences(
                of: String(format:"READING%d", (i+1)),
                with: text.string)
            
        }
        
        let title = "<p align=\"center\"><b>" + Translate.s(data[index.row]) + "</b></p>"
        
        return title + content
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

