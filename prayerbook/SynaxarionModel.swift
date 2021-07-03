//
//  SynaxarionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 5/27/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class SynaxarionModel : BookModel {
    var code: String = "Synaxarion"
    var title = "Синаксари Постной и Цветной Триоди"
    var mode: BookType = .text
    
    var isExpandable = false
    var hasDate = false
    var date: Date = Date()
    
    var currentYear : Int = 0
    
    var dates = [Date]()
    
    static let shared = SynaxarionModel()
    
    let data : [(String,String)]  = [
        ("Синаксарь в неделю о мытаре и фарисее", "synaxarion1"),
        ("Синаксарь в неделю о блудном сыне", "synaxarion2"),
        ("Синаксарь в субботу мясопустную", "synaxarion3"),
        ("Синаксарь в неделю мясопустную, о Страшном Суде", "synaxarion4"),
        ("Синаксарь в субботу Сырной седмицы", "synaxarion5"),
        ("Синаксарь в неделю сыропустную", "synaxarion6"),
        ("Синаксарь в субботу первой седмицы Великого поста", "synaxarion7"),
        ("Синаксарь в неделю первую Великого поста", "synaxarion8"),
        ("Синаксарь в неделю вторую Великого поста", "synaxarion9"),
        ("Синаксарь в неделю третью Великого поста", "synaxarion10"),
        ("Синаксарь в неделю четвертую Великого поста", "synaxarion11"),
        ("Синаксарь в четверток пятой седмицы Великого поста", "synaxarion12"),
        ("Синаксарь в субботу пятой седмицы Великого поста", "synaxarion13"),
        ("Синаксарь в Лазареву субботу", "synaxarion14"),
        ("Синаксарь в Неделю ваий", "synaxarion15"),
        ("Синаксарь во Святой Великий Понедельник", "synaxarion16"),
        ("Синаксарь во Святой Великий Вторник", "synaxarion17"),
        ("Синаксарь во Святую Великую Среду", "synaxarion18"),
        ("Синаксарь во Святой Великий Четверг", "synaxarion19"),
        ("Синаксарь во Святую Великую Пятницу", "synaxarion20"),
        ("Синаксарь во Святую Великую Субботу", "synaxarion21"),
        ("Синаксарь во Святую и Великую неделю Пасхи", "synaxarion22"),
        ("Синаксарь на Пресвятую Госпожу Владычицу Богородицу, Живоприемный Источник", "synaxarion23"),
        ("Синаксарь в неделю Фомину", "synaxarion24"),
        ("Синаксарь в неделю третью по Пасце, святых жен мироносиц", "synaxarion25"),
        ("Синаксарь в неделю четвертую по Пасце, о разслабленом", "synaxarion26"),
        ("Синаксарь в среду разслабленного, на преполовение Пятидесятницы", "synaxarion27"),
        ("Синаксарь в неделю пятую по Пасце, о самаряныне", "synaxarion28"),
        ("Синаксарь в неделю шестую по Пасце, о слепом", "synaxarion29"),
        ("Синаксарь в неделю святых 318 богоносных отец, иже в Никеи", "synaxarion30"),
        ("Синаксарь на Вознесение Господа Бога и Спаса нашего Иисуса Христа", "synaxarion31"),
        ("Синаксарь в неделю святыя Пентикостии", "synaxarion32"),
        ("Синаксарь в понедельник по Пятидесятнице, сиесть Святаго Духа", "synaxarion33"),
        ("Синаксарь в неделю Всех Святых", "synaxarion34"),
    ]
    
    func getSections() -> [String] {
        return [""]
    }
    
    func getItems(_ section: Int) -> [String] {
        return data.map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getTitle(at pos: BookPosition) -> String? {
        return data[pos.index!.row].0
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        let prefs = AppGroup.prefs!
        let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
        let filename = pos.location ?? data[pos.index!.row].1
        
        if let rtfPath = Bundle.main.url(forResource: filename, withExtension: "rtf") {
            do {
                let opts : [NSAttributedString.DocumentReadingOptionKey : Any] =
                    [.documentType : NSAttributedString.DocumentType.rtf]
                
                let content = try NSAttributedString(url: rtfPath, options:opts, documentAttributes: nil)
                
                return content
                    .colored(with: Theme.textColor)
                    .font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
            } catch _ { }
        }
        
        return nil
    }
    
    func getSynaxarion(for date: Date) -> (String,String)? {
        let year = DateComponents(date: date).year!

        if year != currentYear {
            currentYear = year
            
            let pascha = Cal.d(.pascha)
            let greatLentStart = pascha-48.days
            let palmSunday = Cal.d(.palmSunday)
            
            dates = [
                greatLentStart-22.days,greatLentStart-15.days,greatLentStart-9.days,greatLentStart-8.days,
                greatLentStart-2.days,greatLentStart-1.days,greatLentStart+5.days,greatLentStart+6.days,
                greatLentStart+13.days,greatLentStart+20.days,greatLentStart+27.days,greatLentStart+31.days,
                greatLentStart+33.days,palmSunday-1.days,palmSunday,palmSunday+1.days,
                palmSunday+2.days,palmSunday+3.days,palmSunday+4.days,palmSunday+5.days,
                palmSunday+6.days,pascha, pascha+5.days,pascha+7.days,pascha+14.days,
                pascha+21.days, pascha+24.days,pascha+28.days,pascha+35.days,
                pascha+42.days,pascha+39.days,pascha+49.days, pascha+50.days, pascha+56.days,
            ]
        }
        
        if let index = dates.firstIndex(of: date) {
            return data[index]
            
        } else {
            return nil
        }
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
        if let index = pos.index {
            return "\(code)_\(index.section)_\(index.row)"
            
        } else if let filename = pos.location,
            let index = data.firstIndex(where: { $0.1 == filename } ) {
            return "\(code)_0_\(index)"
        }
        
        return ""
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        let comp = bookmark.components(separatedBy: "_")
        guard comp[0] == code else { return "" }
        
        let row = Int(comp[2])!
        return data[row].0
    }

}

