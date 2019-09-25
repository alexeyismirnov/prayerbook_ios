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

extension String {
    var paragraph: String {
        return self.count > 0 ? "<p>\(self)</p>" : ""
    }
    
    var title: String {
        return self.count > 0 ? "<p class=\"rubric\">\(self)</p>" : ""
    }
}


class TypikaModel : BookModel {
    var code: String = "Typika"
    
    var title: String {
        get { return Translate.s("Typika Reader Service") }
    }
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasDate = true
    
    var tone: Int!
    
    var beatitudes = [String]()
    var prokimen = [String]()
    var prokimen_tone = [Int]()
    var alleluia = [String]()
    var alleluia_tone: Int!
    var troparion = [(String,String)]()
    var kontakion = [(String,String)]()
    
    let default_kontakia = [("", "Со святыми упокой  Христе, души раб Твоих,  идеже несть болезнь, ни печаль,  ни воздыхание,  но жизнь безконечная"),
    ("", "Предстательство христиан непостыдное,  ходатайство ко Творцу непреложное,  не презри грешных молений гласы,  но предвари, яко Благая, на помощь нас, верно зовущих Ти:  ускори на молитву и потщися на умоление,  предстательствующи присно, Богородице, чтущих Тя.")]

    func resetData() {
        beatitudes = [String]()
        prokimen = [String]()
        prokimen_tone = [Int]()
        
        alleluia = [String]()
        troparion = [(String,String)]()
        kontakion = [(String,String)]()
    }
    
    func makeSingleProkimenon() {
        prokimen.append(contentsOf: prokimen[0].components(separatedBy: "/"))
        prokimen[0] = prokimen[0].replacingOccurrences(of: "/", with: " ")
    }
    
    func sundayProkimenAlleluia() {
        prokimen_tone = [tone]
                       
        let _ = try! db.selectFrom("prokimen_sun", whereExpr:"glas=\(tone!)", orderBy: "id")
           { prokimen.append($0.stringValue("text") ?? "") }

        makeSingleProkimenon()

        alleluia_tone = tone

        let _ = try! db.selectFrom("alleluia_sun", whereExpr:"glas=\(tone!)", orderBy: "id")
           { alleluia.append($0.stringValue("text") ?? "") }
    }
    
    var date: Date = Date() {
        didSet {
            tone = Cal.getTone(date)!
            
            resetData()
            
            let _ = try! db.selectFrom("blazh_sun", whereExpr:"glas=\(tone!)", orderBy: "id")
                                  { beatitudes.append($0.stringValue("text") ?? "") }
            
            let _ = try! db.selectFrom("tropar_sun", whereExpr:"glas=\(tone!)")
            { troparion.append(("Тропарь воскресный, глас \(tone!):", $0.stringValue("text") ?? "")) }
           
            if Cal.d(.sundayOfPublicianAndPharisee) ... Cal.d(.pentecost)+7.days ~= date {
                let week_num = (Cal.d(.sundayOfPublicianAndPharisee) >> date) / 7
                
                beatitudes.removeLast()
                beatitudes.removeLast()

                let _ = try! db.selectFrom("blazh_triod", whereExpr:"week=\(week_num)", orderBy: "id")
                { beatitudes.append($0.stringValue("text") ?? "") }
                
                let _ = try! db.selectFrom("kondak_triod", whereExpr:"week=\(week_num)")
                { kontakion.append(($0.stringValue("title") ?? "", $0.stringValue("text") ?? "")) }
                
                if (date == Cal.d(.sundayOfPublicianAndPharisee) || date == Cal.d(.sundayOfProdigalSon)) {
                    sundayProkimenAlleluia()

                } else {
                    let _ = try! db.selectFrom("prokimen_triod", whereExpr:"week=\(week_num)", orderBy: "id")
                    { prokimen_tone.append($0.intValue("glas") ?? 0)
                      prokimen.append($0.stringValue("text") ?? "") }
                
                    makeSingleProkimenon()

                    let _ = try! db.selectFrom("alleluia_triod", whereExpr:"week=\(week_num)", orderBy: "id")
                    { alleluia_tone = ($0.intValue("glas") ?? 0)
                      alleluia.append($0.stringValue("text") ?? "") }
                }
                
            } else {
                sundayProkimenAlleluia()

                let _ = try! db.selectFrom("kondak_sun", whereExpr:"glas=\(tone!)")
                           { kontakion.append(("Кондак воскресный, глас \(tone!):", $0.stringValue("text") ?? "")) }
                           
                kontakion.append(contentsOf: default_kontakia)
            }
            
            while beatitudes.count < 12 {
                beatitudes.insert("", at: 0)
            }
            
            while troparion.count < 3 {
                troparion.append(("", ""))
            }
            
            while kontakion.count < 3 {
                kontakion.insert(("",""), at: 0)
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
        "Послание к Римлянам": "К Римляном послания святаго Апостола Павла",
        "послание к Коринфянам": "К Коринфяном послания святаго Апостола Павла",
        "Послание к Галатам": " К Галатом послания святаго Апостола Павла",
        "Послание к Ефесянам": "Ко Ефесеем послания святаго Апостола Павла",
        "Послание к Филиппийцам": "К Филипписием послания святаго Апостола Павла",
        "Послание к Колоссянам": "К Колоссаем послания святаго Апостола Павла",
        "послание к Фессалоникийцам": "К Солуняном послания святаго Апостола Павла",
        "послание к Тимофею": "К Тимофею послания святаго Апостола Павла",
        "Послание к Титу": "К Титу послания святаго Апостола Павла",
        "Послание к Филимону": "К Филимону послания святаго Апостола Павла",
        "Послание к Евреям": "Ко Евреем послания святаго Апостола Павла",
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
        
        for (i, text) in beatitudes.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"BLAZH%d!", i+1),
                with: text.paragraph)
        }
        
        for (i, text) in troparion.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"TROPAR%d", i+1),
                with: text.0.title + text.1.paragraph)
        }
        
        for (i, text) in kontakion.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"KONDAK%d", i+1),
                with: text.0.title + text.1.paragraph)
        }
        
        content = content.replacingOccurrences(of: "PROKIMEN0", with: "Вонмем. Премудрость. Прокимен, глас \(prokimen_tone[0]).")

        for (i, text) in prokimen.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"PROKIMEN%d", i+1),
                with: text)
        }
        
        content = content.replacingOccurrences(of: "ALLELUIA0", with: "Аллилуия, глас \(alleluia_tone!).")

        for (i, text) in alleluia.enumerated() {
            content = content.replacingOccurrences(
                of: String(format:"ALLELUIA%d", i+1),
                with: text)
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
                
            } while (nextDate == pascha-7.days ||
                    nextDate == pascha ||
                    nextDate == pascha+49.days)
          
            
            return nextDate
        })
    }
    
    
}

