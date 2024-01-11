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

fileprivate extension String {
    var paragraph: String {
        return self.count > 0 ? "<p>\(self)</p>" : ""
    }
    
    var title: String {
        return self.count > 0 ? "<p class=\"rubric\">\(self)</p>" : ""
    }
}


class TypikaModel : ServiceModel {
    let t_alleluia_sun = Table("alleluia_sun")
    let t_alleluia_triod = Table("alleluia_triod")
    
    let t_blazh_sun = Table("blazh_sun")
    let t_blazh_triod = Table("blazh_triod")
    
    let t_tropar_sun = Table("tropar_sun")
    let t_tropar_triod = Table("tropar_triod")
    
    let t_kondak_sun = Table("kondak_sun")
    let t_kondak_triod = Table("kondak_triod")
    
    let t_prokimen_sun = Table("prokimen_sun")
    let t_prokimen_triod = Table("prokimen_triod")
    
    let t_content = Table("content")
    let t_content_lent = Table("content_lent")
    
    let f_id = Expression<Int>("id")
    let f_week = Expression<Int>("week")
    let f_section = Expression<Int>("section")
    let f_glas = Expression<Int>("glas")
    let f_title = Expression<String>("title")
    let f_text = Expression<String>("text")

    static let shared = TypikaModel()
    
    var lang = Translate.language
    var code: String = "Typika"
    
    var title: String {
        get { return Translate.s("Typika Reader Service") }
    }
    
    var author: String?
    var contentType: BookContentType = .html
    
    var hasChapters = false
    
    var cal: Cal!

    var content: String!
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

    var db : Connection

    init() {
        let path = Bundle.main.path(forResource: "typika", ofType: "sqlite")!
        db = try! Connection(path, readonly: true)
    }
    
    func resetData() {
        beatitudes = [String]()
        prokimen = [String]()
        prokimen_tone = [Int]()
        
        alleluia = [String]()
        troparion = [(String,String)]()
        kontakion = [(String,String)]()
    }
    
    func getProkimenonTriod(_ week_num: Int) {
        try! Array(db.prepareRowIterator(t_prokimen_triod.filter(f_week == week_num).order(f_id)))
            .forEach({
            prokimen_tone.append($0[f_glas])
            prokimen.append($0[f_text])
        })
    }
    
    func getProkimenonSundayTriod(_ week_num: Int) {
        try! Array(db.prepareRowIterator(t_prokimen_sun.filter(f_glas == tone).order(f_id)))
            .forEach({
            prokimen_tone.append(tone)
            prokimen.append($0[f_text])
        })
        
        try! Array(db.prepareRowIterator(t_prokimen_triod.filter(f_week == week_num).order(f_id)))
            .forEach({
            prokimen_tone.append($0[f_glas])
            prokimen.append($0[f_text])
        })
    }
    
    func makeSingleProkimenon() {
        prokimen.append(contentsOf: prokimen[0].components(separatedBy: "/"))
        prokimen[0] = prokimen[0].replacingOccurrences(of: "/", with: " ")
    }
    
    func makeDoubleProkimenon() {
        prokimen.append(prokimen[2])
        
        prokimen[2] = "Ин прокимен, глас \(prokimen_tone[2]). " + prokimen[2]
        prokimen[0] = prokimen[0].replacingOccurrences(of: "/", with: " ")
    }
    
    func getAlleluiaSundayTriod(_ week_num: Int) {
        try! Array(db.prepareRowIterator(t_alleluia_sun.filter(f_glas == tone).order(f_id)))
            .forEach({
            alleluia.append($0[f_text])
        })
        
        alleluia.removeLast()
        
        try! Array(db.prepareRowIterator(t_alleluia_triod.filter(f_week == week_num).order(f_id)))
            .forEach({
            alleluia.append($0[f_text])
        })
        
        alleluia_tone = tone
    }
    
    func getAlleluiaTriod(_ week_num: Int) {
        try! Array(db.prepareRowIterator(t_alleluia_triod.filter(f_week == week_num).order(f_id)))
            .forEach({
            alleluia_tone = $0[f_glas]
            alleluia.append($0[f_text])
        })
    }
    
    func sundayProkimenAlleluia() {
        try! Array(db.prepareRowIterator(t_prokimen_sun.filter(f_glas == tone).order(f_id)))
            .forEach({
            prokimen_tone.append(tone)
            prokimen.append($0[f_text])
        })

        makeSingleProkimenon()

        alleluia_tone = tone
        
        try! Array(db.prepareRowIterator(t_alleluia_sun.filter(f_glas == tone).order(f_id)))
            .forEach({
            alleluia.append($0[f_text])
        })
    }
    
    var week_num: Int {
        return (cal.d("sundayOfPublicianAndPharisee") >> date) / 7
    }
    
    var date: Date = Date() {
        didSet {
            cal = Cal.fromDate(date)
            tone = cal.getTone(date)!
            
            resetData()
            
            try! Array(db.prepareRowIterator(t_blazh_sun.filter(f_glas == tone).order(f_id)))
                .forEach({
                    beatitudes.append($0[f_text])
            })
            
            try! Array(db.prepareRowIterator(t_tropar_sun.filter(f_glas == tone)))
                .forEach({
                    troparion.append(("Тропарь воскресный, глас \(tone!):", $0[f_text]))
            })
            
            if cal.pascha ... cal.pentecost+7.days ~= date {
                beatitudes.removeAll()
                
                try! Array(db.prepareRowIterator(t_blazh_triod.filter(f_week == week_num).order(f_id)))
                    .forEach({
                        beatitudes.append($0[f_text])
                })
                
                if date == cal.d("sunday2AfterPascha") {
                    troparion.removeAll()
                }
                
                try! Array(db.prepareRowIterator(t_tropar_triod.filter(f_week == week_num)))
                    .forEach({
                        troparion.append(($0[f_title], $0[f_text]))
                })
                
                try! Array(db.prepareRowIterator(t_kondak_triod.filter(f_week == week_num)))
                    .forEach({
                        kontakion.append(($0[f_title], $0[f_text]))
                })
                
                if cal.pascha+14.days ... cal.d("ascension") ~= date && date != cal.d("sunday5AfterPascha") {
                    kontakion.append(("Кондак Пасхи, глас 8:", "Аще и во гроб снизшел еси, Безсмертне, / но адову разрушил еси силу, / и воскресл еси, яко победитель, Христе Боже, / женам мироносицам вещавый: радуйтеся, / и Твоим апостолом мир даруяй, / падшим подаяй воскресение."))
                }
                
                getProkimenonTriod(week_num)

                if date == cal.pentecost+7.days {
                    makeDoubleProkimenon()
                } else {
                    makeSingleProkimenon()
                }
                
                getAlleluiaTriod(week_num)

                
            } else if cal.d("sundayOfPublicianAndPharisee") ... cal.pascha ~= date {
                
                if cal.greatLentStart ... cal.pascha ~= date {
                    beatitudes.removeAll()
                    
                    while beatitudes.count < 11 {
                        beatitudes.append("Помяни нас, Господи, егда приидеши во Царствии Твоем.")
                    }
                    
                    let poklon = "<span class=\"rubric\">(Поклон великий)</span>"
                    beatitudes.append("""
                        Помяни нас, Господи, егда приидеши во Царствии Твоем.<br>
                        Помяни нас, Господи, егда приидеши во Царствии Твоем. \(poklon)<br>
                        Помяни нас, Владыко, егда приидеши во Царствии Твоем. \(poklon)<br>
                        Помяни нас, Святый, егда приидеши во Царствии Твоем. \(poklon)<br>
                        """)

                } else {
                    beatitudes.removeLast()
                    beatitudes.removeLast()
                    
                    try! Array(db.prepareRowIterator(t_blazh_triod.filter(f_week == week_num).order(f_id)))
                        .forEach({
                            beatitudes.append($0[f_text])
                    })
                }
                
                try! Array(db.prepareRowIterator(t_tropar_triod.filter(f_week == week_num)))
                    .forEach({
                        troparion.append(($0[f_title], $0[f_text]))
                })
                
                try! Array(db.prepareRowIterator(t_kondak_triod.filter(f_week == week_num)))
                    .forEach({
                        kontakion.append(($0[f_title], $0[f_text]))
                })
                
                if (date == cal.d("sundayOfPublicianAndPharisee") || date == cal.d("sundayOfProdigalSon")) {
                    sundayProkimenAlleluia()
                    
                } else if (date == cal.greatLentStart + 13.days) {
                    getProkimenonTriod(week_num)
                    makeDoubleProkimenon()
                    
                    getAlleluiaSundayTriod(week_num)
                    
                } else if (date == cal.greatLentStart + 27.days || date == cal.greatLentStart + 34.days) {
                    getProkimenonSundayTriod(week_num)
                    makeDoubleProkimenon()

                    getAlleluiaSundayTriod(week_num)
                    
                    try! Array(db.prepareRowIterator(t_kondak_sun.filter(f_glas == tone)))
                        .forEach({
                            kontakion.append(("Кондак воскресный, глас \(tone!):", $0[f_text]))
                    })

                } else {
                    getProkimenonTriod(week_num)
                    makeSingleProkimenon()

                    getAlleluiaTriod(week_num)
                }
                
            } else {
                sundayProkimenAlleluia()
                
                try! Array(db.prepareRowIterator(t_kondak_sun.filter(f_glas == tone)))
                    .forEach({
                        kontakion.append(("Кондак воскресный, глас \(tone!):", $0[f_text]))
                })
                           
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
    
    func getSections() -> [String] { return [""] }

    var data: [String] {
        get {
            if cal.greatLentStart ... cal.pascha ~= date {
                return [
                    "Блаженны",
                    "Тропарь и Трисвятое",
                    "Чтение Апостола",
                    "Чтение Евангелия",
                    "Символ веры",
                    "Молитва Господня",
                    "Кондаки",
                    "Молитва Св. Ефрема Сирина",
                    "Молитва «Всесвятая Троица»",
                    "Отпуст"
                ]
            } else {
                return  [
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
            }
        }
    }
    
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
    
    
    func getBookTitle(title: String) -> String {
        let regex = try! NSRegularExpression(pattern:"\\d-..", options: .caseInsensitive)
        var titleStr = title

        titleStr = regex.stringByReplacingMatches(
           in: titleStr,
           options: [],
           range: NSRange(titleStr.startIndex..., in: titleStr),
           withTemplate: "")
        
        return bookTitle[titleStr]! + " чтение."
    }
    
    func getReading(_ readingStr: String, index : Int) {
        let readings = PericopeModel(lang: "ru").getPericope(readingStr, decorated: false)

        let (title1, text1) = readings[0]
        let (title2, text2) = readings[1]
        
        content = content.replacingOccurrences(
                       of: String(format:"EPISTLE_TITLE%d", index),
                       with: getBookTitle(title: title1.string).paragraph)
                   
        content = content.replacingOccurrences(
           of: String(format:"EPISTLE_READING%d", index),
           with: text1.string.paragraph)
        
        content = content.replacingOccurrences(
                       of: String(format:"GOSPEL_TITLE%d", index),
                       with: getBookTitle(title: title2.string).paragraph)
                   
        content = content.replacingOccurrences(
           of: String(format:"GOSPEL_READING%d", index),
           with: text2.string.paragraph)

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
    
    func getTitle(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return nil }
        return  Translate.s(data[index.row])
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        var typika: [String]
            
        if cal.greatLentStart ... cal.pascha ~= date {
            typika = try! db.prepareRowIterator(t_content_lent
                .filter(f_section == index.row+1))
                .map { $0[f_text] }

        } else {
            typika = try! db.prepareRowIterator(t_content
                .filter(f_section == index.row+1))
            .map { $0[f_text] }
        }
        
        content = typika.joined()
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
        
        let readingStr = ChurchReading.forDate(date).last!.components(separatedBy: "#").first!
        getReading(readingStr, index: 1)
        
        let lentReading = [
            cal.greatLentStart+13.days: "Heb 7:26-8:2 John 10:9-16",
            cal.greatLentStart+27.days: "Ephes 5:8-19 Matthew 4:25-5:12",
            cal.greatLentStart+34.days: "Gal 3:23-29 Luke 7:36-50",
        ]
        
        if let readingStr = lentReading[date] {
            getReading(readingStr, index: 2)
            
        } else {
            content = content.replacingOccurrences(of: "EPISTLE_TITLE2", with: "")
            content = content.replacingOccurrences(of: "EPISTLE_READING2", with: "")
            content = content.replacingOccurrences(of: "GOSPEL_TITLE2", with: "")
            content = content.replacingOccurrences(of: "GOSPEL_READING2", with: "")
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
        var nextDate = Cal.nearestSundayAfter(startDate)
        var prevDate : Date!
        
        return AnyIterator({
            repeat {
                prevDate = nextDate
                nextDate = nextDate + 7.days
                
            } while (!Cal.getGreatFeast(prevDate).isEmpty)
                    
            return prevDate
        })
    }
    
    
}

