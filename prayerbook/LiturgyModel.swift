//
//  LiturgyModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 4/5/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal

class LiturgyModel : BookModel {
    var code: String = "Liturgy"
    var mode: BookType = .html

    var isExpandable = false
    var hasNavigation = true
    
    static let data: [[String]] = [
        ["Начинательные возгласы диакона и священника",
         "Великая ектения",
         "Первыи антифон",
         "Малая ектения",
         "Второи антифон",
         "Гимн «Единородныи Сыне»",
         "Малая ектения",
         "Третии антифон, Блаженны",
         "Малыи вход с Евангелием",
         "Тропари и кондаки",
         "Возглас священника перед Трисвятым",
         "Трисвятое",
         "Прокимен",
         "Чтение Апостола и аллилуарии",
         "Чтение Евангелия",
         "Сугубая ектения",
         "Заупокоиная ектения",
         "Ектения об оглашенных",
         "Ектения о выходе оглашенных"],
        
        ["Сокращенная великая ектения",
         "Малая ектения",
         "Пение 1-и части «Херувимскои песни»",
         "Великии вход",
         "Пение 2-и части «Херувимскои песни»",
         "1-я просительная ектения (приготовление молящихся к освящению Даров)",
         "Целование мира",
         "Символ веры",
         "Последнии призыв перед Анафорои",
         "Анафора (Евхаристическии канон)",
         "Прославление Божиеи Матери",
         "Поминовение «и всех и вся»",
         "2-я просительная ектения",
         "Молитва Господня",
         "Молитва главопреклонения",
         "Молитвы перед причащением мирян",
         "Возглас «Спаси, Боже, люди Твоя» и стихира «Видехом свет истинныи»",
         "Песнь «Да исполнятся уста наша»",
         "Благодарственная ектения",
         "Заамвонная молитва",
         "Благословение священником молящихся",
         "Псалом 33",
         "Возглас и молитвы перед отпустом",
         "Отпуст",
         "Многолетие"]]
    
    static let shared = LiturgyModel()
    var db : Database!
    
    init() {
        let path = Bundle.main.path(forResource: "liturgy", ofType: "sqlite")!
        db = try! Database(path:path)
    }
    
    func getTitle() -> String {
        return "Божественная Литургия свт. Иоанна Златоуста с комментариями"
    }
    
    func getSections() -> [String] {
        return ["Литургия оглашенных", "Литургия верных"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return LiturgyModel.data[section]
    }

    func getNumChapters(_ index: IndexPath) -> Int {
        return 0;
    }
    
    func getData(_ index: IndexPath) -> String {
        var res = ""
        var comments = [Int: Int]()
        let section = (index.section == 0) ? index.row+1 : LiturgyModel.data[0].count + index.row+1

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
        
        let title = "<p align=\"center\"><b>" + LiturgyModel.data[index.section][index.row] + "</b></p>"
        
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
    
    func getBookmark(at pos: BookPosition) -> String {
        guard let index = pos.index else { return "" }
        return "Liturgy_\(index.section)_\(index.row)"
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == "Liturgy" else { return "" }
        
        return "Божественная Литургия - " + LiturgyModel.data[Int(comp[1])!][Int(comp[2])!]
    }

    func getNextSection(at pos: BookPosition) -> BookPosition? {
        guard let index = pos.index else { return nil }

        if (index.section == 1 && index.row == LiturgyModel.data[1].count-1) {
            return nil
        } else if (index.section == 0 && index.row == LiturgyModel.data[0].count-1) {
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
            return BookPosition(index: IndexPath(row: LiturgyModel.data[0].count-1, section: 0), chapter: 0)
        } else {
            return BookPosition(index: IndexPath(row: index.row-1, section: index.section), chapter: 0)
        }
    }
}

