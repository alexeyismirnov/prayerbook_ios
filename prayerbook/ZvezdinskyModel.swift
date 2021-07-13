//
//  ZvezdinskyModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/31/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import Squeal
import swift_toolkit

class ZvezdinskyModel : BookModel {
    var code: String = "Zvezdinsky"
    var title = "Сщмч. Серафим (Звездинский), епископ Дмитровский. Хлеб Небесный. Проповеди о Божественной Литургии."
    var contentType: BookContentType = .text
    
    var hasChapters = false
    var hasDate = false
    var date: Date = Date()
    
    var db : Database

    static let shared = ZvezdinskyModel()

    let data : [String] = [
        "Проповедь 1. О Божественной литургии",
        "Проповедь 2. О Ветхозаветной Церкви и Божественной литургии",
        "Проповедь 3. О первой Божественной литургии",
        "Проповедь 4. О Божественной литургии в древние времена",
        "Проповедь 5. Постоянный чин Божественной литургии святых Василия Великого и Иоанна Златоуста",
        "Проповедь 6. О храме",
        "Проповедь 7. О троичности Божественной литургии",
        "Проповедь 8. Проскомидия",
        "Проповедь 9. Литургии оглашенных",
        "Проповедь 10. Антифоны",
        "Проповедь 11. О земной жизни Господа Иисуса Христа",
        "Проповедь 12. Чтение Евангелия — проповедь Спасителя",
        "Проповедь 13. О том, как молиться во время Божественной литургии",
        "Проповедь 14. О значении Божественной литургии",
        "Проповедь 15. Об омывании рук и чистоте душевной",
        "Проповедь 16. Божественная литургия как благость, милость, подарок Иисуса Христа",
        "Проповедь 17. Первая часть Евхаристического канона (прославление)",
        "Проповедь 18  Вторая часть Евхаристического канона (Серафимская песнь)",
        "Проповедь 19. Серафимская песнь (продолжение)",
        "Проповедь 20. Третья часть Евхаристического канона (возношение Святых Даров)",
        "Проповедь 21. Четвёртая часть Евхаристического канона (освящение Святых Даров)",
    ]
    
    init() {
        let path = Bundle.main.path(forResource: "zvezdinsky", ofType: "sqlite")!
        db = try! Database(path:path)
    }
    
    func getSections() -> [String] {
        return [""]
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
    
    func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        let prefs = AppGroup.prefs!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        
        let results = try! db.selectFrom("content", whereExpr:"chapter=\"\(index.row+1)\"") { ["text": $0["text"]] }
        
        if let res = results[safe: 0] {
            let content = NSAttributedString(string: res["text"] as! String)
            return
                data[index.row].colored(with: Theme.textColor).boldFont(ofSize: CGFloat(fontSize)).centered +
                    "\n\n" +
                content.colored(with: Theme.textColor).font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
        }
        
        return nil
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
    
    func getBookmark(at pos: BookPosition) -> String? {
        guard let index = pos.index else { return "" }
        return "\(code)_\(index.section)_\(index.row)"
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        let row = Int(comp[2])!
        return data[row]
    }
}



