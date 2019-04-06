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
    
    func getTitle() -> String {
        return "Божественная Литургия"
    }
    
    func getSections() -> [String] {
        return ["Литургия оглашенных", "Литургия верных"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return LiturgyModel.data[section]
    }
    
    func isExpandable() -> Bool {
        return false;
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0;
    }
    
    func getData(_ index: IndexPath) -> String {
        var res = ""
        let section = (index.section == 0) ? index.row+1 : LiturgyModel.data[0].count + index.row+1
        
        let path = Bundle.main.path(forResource: "liturgy", ofType: "sqlite")!
        let db = try! Database(path:path)

        let saintsDB = try! db.selectFrom("content", whereExpr:"section=\(section)", orderBy: "row")
            { ["author": $0["author"], "text": $0["text"]] }
        
        for line in saintsDB {
            var author = line["author"] as! String
            var text = line["text"] as! String
            
            text = text.replacingOccurrences(of: "\n", with: "<br/>")
            
            if author == "Иере́й:" {
                author = "<font color=\"red\">\(author)</font>"
            }
            
            res += "<i>\(author)</i> \(text)<br><br>"
        }
        
        let title = "<p align=\"center\"><b>" + LiturgyModel.data[index.section][index.row] + "</b></p>"
        
        return title + res
    }
    
    func getVC(index: IndexPath, chapter: Int) -> UIViewController {
        let vc = WebDocument()
        vc.content = getData(index)
        
        return vc
    }
    

}

