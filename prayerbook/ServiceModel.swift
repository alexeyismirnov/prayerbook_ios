//
//  LiturgyModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 4/5/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

protocol ServiceModel  {
    var data: [[String]] { get }
    var db : Database { get }
    var shortTitle : String { get }
}

extension ServiceModel where Self: BookModel {
    func getItems(_ section: Int) -> [String] {
        return data[section]
    }

    func getNumChapters(_ index: IndexPath) -> Int {
        return 0;
    }
    
    func getData(_ index: IndexPath) -> String {
        var res = ""
        var comments = [Int: Int]()
        let section = (index.section == 0) ? index.row+1 : data[0].count + index.row+1
        
        let liturgyDB = try! db.selectFrom("content", whereExpr:"section=\(section)", orderBy: "row")
        { ["author": $0["author"], "text": $0["text"], "row": $0["row"]] }
        
        let commentsDB = try! db.selectFrom("comments", whereExpr:"section=\(section)", orderBy: "row")
        { [ "id": $0["id"], "row": $0["row"]] }
        
        for line in commentsDB {
            let id = line["id"] as! Int64
            let row = line["row"] as! Int64
            comments[Int(row)] = Int(id)
        }
        
        for line in liturgyDB {
            var author = line["author"] as! String
            var text = line["text"] as! String
            let row = Int(line["row"] as! Int64)
            
            text = text.replacingOccurrences(of: "\n", with: "<br/>")
            
            let pattern = "comment_(\\d+)"
            let regex = try! NSRegularExpression(pattern: pattern)
            
            if regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).count > 0 {
                let text2 = NSMutableString(string: text)
                
                regex.replaceMatches(in: text2, options: .reportProgress, range: NSRange(location: 0,length: text2.length), withTemplate: "&nbsp;&nbsp;<a href=\"comment://$1\"><img class=\"icon\"/></a>&nbsp;&nbsp;")
                
                text = String(text2)
            }
            
            if author == "Иере́й:" {
                author = "<font color=\"red\">\(author)</font>"
            }
            
            res += "<i>\(author)</i> \(text)"
            if comments[row] != nil {
                let id = Int(comments[row]!)
                res += "&nbsp;&nbsp;<a href=\"comment://\(id)\"><img class=\"icon\"/></a>"
            }
            
            res += "<br><br>"
        }
        
        let title = "<p align=\"center\"><b>" + data[index.section][index.row] + "</b></p>"
        
        return title + res
    }
    
    func getComment(commentId: Int) -> String? {
        let commentsDB = try! db.selectFrom("comments", whereExpr:"id=\(commentId)") { [ "text": $0["text"]] }
        
        if let result = commentsDB.first {
            return result["text"] as? String
            
        } else {
            return nil
        }
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        return getData(index)
    }
    
    func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return "" }
        return "\(code)_\(index.section)_\(index.row)"
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        return "\(shortTitle) - " + data[Int(comp[1])!][Int(comp[2])!]
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }
        
        if (index.section == 1 && index.row == data[1].count-1) {
            return nil
        } else if (index.section == 0 && index.row == data[0].count-1) {
            return BookPosition(index: IndexPath(row: 0, section: 1), chapter: 0)
        } else {
            return BookPosition(index: IndexPath(row: index.row+1, section: index.section), chapter: 0)
        }
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }
        
        if (index.section == 0 && index.row == 0) {
            return nil
        } else if (index.section == 1 && index.row == 0) {
            return BookPosition(index: IndexPath(row: data[0].count-1, section: 0), chapter: 0)
        } else {
            return BookPosition(index: IndexPath(row: index.row-1, section: index.section), chapter: 0)
        }
    }
    
}

class LiturgyModel : BookModel, ServiceModel {
    var code: String = "Liturgy"
    var title = "Божественная Литургия свт. Иоанна Златоуста с комментариями"
    var shortTitle: String = "Божественная Литургия"
    
    var mode: BookType = .html

    var isExpandable = false
    var hasDate = false
    var date: Date = Date()
    
    var db : Database
    
    func getSections() -> [String] {
        return ["Литургия оглашенных", "Литургия верных"]
    }
    
    var data: [[String]] = [
        ["Начинательные возгласы диакона и священника",
         "Великая ектения",
         "Первый антифон",
         "Малая ектения",
         "Второй антифон",
         "Гимн «Единородный Сыне»",
         "Малая ектения",
         "Третий антифон, Блаженны",
         "Малыи вход с Евангелием",
         "Тропари и кондаки",
         "Возглас священника перед Трисвятым",
         "Трисвятое",
         "Прокимен",
         "Чтение Апостола и аллилуарии",
         "Чтение Евангелия",
         "Сугубая ектения",
         "Заупокойная ектения",
         "Ектения об оглашенных",
         "Ектения о выходе оглашенных"],
        
        ["Сокращенная великая ектения",
         "Малая ектения",
         "Пение 1-й части «Херувимской песни»",
         "Великий вход",
         "Пение 2-й части «Херувимской песни»",
         "1-я просительная ектения (приготовление молящихся к освящению Даров)",
         "Целование мира",
         "Символ веры",
         "Последний призыв перед Анафорой",
         "Анафора (Евхаристический канон)",
         "Прославление Божиеи Матери",
         "Поминовение «и всех и вся»",
         "2-я просительная ектения",
         "Молитва Господня",
         "Молитва главопреклонения",
         "Молитвы перед причащением мирян",
         "Возглас «Спаси, Боже, люди Твоя» и стихира «Видехом свет истинный»",
         "Песнь «Да исполнятся уста наша»",
         "Благодарственная ектения",
         "Заамвонная молитва",
         "Благословение священником молящихся",
         "Псалом 33",
         "Возглас и молитвы перед отпустом",
         "Отпуст",
         "Многолетие"]]
    
    static let shared = LiturgyModel()
    
    init() {
        let path = Bundle.main.path(forResource: "liturgy", ofType: "sqlite")!
        db = try! Database(path:path)
    }
}

class VespersModel : BookModel, ServiceModel {
    var code: String = "Vespers"
    var title = "Всенощное бдение с комментариями"
    var shortTitle: String = "Всенощное бдение"
    
    var mode: BookType = .html
    
    var isExpandable = false
    var hasDate = false
    var date: Date = Date()
    
    var db : Database
    
    func getSections() -> [String] {
        return ["Великая вечерня ", "Утреня"]
    }
    
    var data: [[String]] = [
        ["Начинательные возгласы диакона и священника",
         "Псалом 103",
         "Великая ектения",
         "Блажен муж (первый антифон 1-й кафизмы, избранные стихи)",
         "Малая ектения",
         "Господи, воззвах: (псалмы 140,141,129,116)",
         "Молитва входа",
         "Вечерняя песнь Сыну Божию «Свете Тихий»",
         "Прокимен",
         "Паремии (чтения) праздника",
         "Чтение Св. Писания",
         "Сугубая ектения",
         "Молитва при наступлении вечера «Сподоби Господи»",
         "Просительная ектения",
         "Молитва главопреклонения",
         "Лития",
         "Стихиры на стиховне",
         "Молитва Симеона Богоприимца",
         "Молитва на освящение хлебов",
         "Псалом 33"],
        
        ["Шестопсалмие",
         "Великая ектения",
         "Бог Господь",
         "Кафизмы",
         "Полиелей",
         "Тропари воскресные «по Непорочным», глас 5",
         "Малая ектения",
         "Ипакои",
         "Степенны. Первыи антифон 4-го гласа",
         "Прокимен",
         "Второй прокимен",
         "Чтение Евангелия",
         "Воскресная песнь после Евангелия, глас 6",
         "Псалом 50",
         "Прошение «Спаси, Боже, люди Твоя...» после целования Евангелия",
         "Канон",
         "Малая ектения",
         "Свят Господь Бог наш",
         "Стихиры на Хвалитех",
         "Славословие великое",
         "Тропари",
         "Сугубая ектения",
         "Просительная ектения",
         "Молитва главопреклонения",
         "Отпуст",
         "Многолетие",
         "Час первый",
         "Молитва священника"]]

    static let shared = VespersModel()
    
    init() {
        let path = Bundle.main.path(forResource: "vespers", ofType: "sqlite")!
        db = try! Database(path:path)
    }
}

