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
    var mode: BookType = .text
    
    var isExpandable = false
    var hasNavigation = false
    
    static let shared = SynaxarionModel()
    
    static let data : [(String,String)]  = [
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

    func getTitle() -> String {
        return "Синаксари Постной и Цветной Триоди"
    }
    
    func getSections() -> [String] {
        return [""]
    }
    
    func getItems(_ section: Int) -> [String] {
        return SynaxarionModel.data.map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return 0
    }
    
    func getComment(commentId: Int) -> String? {
        return nil
    }
    
    func getContent(at pos: BookPosition) -> Any? {
        if let filename = pos.location {
            return nil
            
        } else if let index = pos.index {
            let filename = SynaxarionModel.data[index.row].1
            let prefs = UserDefaults(suiteName: groupId)!
            let fontSize = CGFloat(prefs.integer(forKey: "fontSize"))
            
            if let rtfPath = Bundle.main.url(forResource: filename, withExtension: "rtf") {
                do {
                    let opts : [NSAttributedString.DocumentReadingOptionKey : Any] =
                        [.documentType : NSAttributedString.DocumentType.rtf]
                    
                    let content = try NSAttributedString(url: rtfPath, options:opts, documentAttributes: nil)
                    return content.font(font: UIFont(name: "TimesNewRomanPSMT", size: CGFloat(fontSize))!)
                    
                } catch let error {
                    print("We got an error \(error)")
                }
            }
            
        }
        return nil
    }
    
    func getBookmark(at pos: BookPosition) -> String {
        return ""
    }
    
    func getNextSection(at pos: BookPosition) -> BookPosition? {
        return nil
    }
    
    func getPrevSection(at pos: BookPosition) -> BookPosition? {
        return nil
    }
    
    func getBookmarkName(_ bookmark: String) -> String {
        return ""
    }

}

