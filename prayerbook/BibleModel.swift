//
//  BibleModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 3/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit

class OldTestamentModel : BookModel {
    static let data: [[(String, String)]] = [
        [
            ("Genesis", "gen"),
            ("Exodus", "ex"),
            ("Leviticus","lev"),
            ("Numbers","num"),
            ("Deuteronomy","deut"),
            ],
        [
            ("Joshua","josh"),
            ("Judges","judg"),
            ("Ruth","ruth"),
            ("1 Samuel","1sam"),
            ("2 Samuel","2sam"),
            ("1 Kings","1kings"),
            ("2 Kings","2kings"),
            ("1 Chronicles","1chron"),
            ("2 Chronicles","2chron"),
            ("Ezra","ezra"),
            ("Nehemiah","neh"),
            ("Esther","esther"),
            ],
        [
            ("Job","job"),
            ("Psalms","ps"),
            ("Proverbs","prov"),
            ("Ecclesiastes","eccles"),
            ("Song of Solomon","song"),
            ],
        
        [
            ("Isaiah","isa"),
            ("Jeremiah","jer"),
            ("Lamentations","lam"),
            ("Ezekiel","ezek"),
            ("Daniel","dan"),
            ("Hosea","hos"),
            ("Joel","joel"),
            ("Amos","amos"),
            ("Obadiah","obad"),
            ("Jonah","jon"),
            ("Micah","mic"),
            ("Nahum","nahum"),
            ("Habakkuk","hab"),
            ("Zephaniah","zeph"),
            ("Haggai","hag"),
            ("Zechariah","zech"),
            ("Malachi","mal"),
            ]
    ]
    
    static let shared = OldTestamentModel()

    func getTitle() -> String {
        return Translate.s("Old Testament")
    }
    
    func getSections() -> [String] {
        return ["Пятикнижие Моисея", "Книги исторические", "Книги учительные", "Книги пророческие"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return OldTestamentModel.data[section].map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return Db.numberOfChapters(OldTestamentModel.data[index.section][index.row].1)
    }
    
    func getVC(index: IndexPath, chapter: Int) -> UIViewController {
        let code =  OldTestamentModel.data[index.section][index.row].1
        let vc = UIViewController.named("Scripture") as! Scripture
        vc.code = .chapter(code, chapter+1)
        
        return vc
    }
    
}

class NewTestamentModel : BookModel {
    static let data: [[(String, String)]] = [
        [
            ("Gospel of St Matthew", "matthew"),
            ("Gospel of St Mark", "mark"),
            ("Gospel of St Luke", "luke"),
            ("Gospel of St John", "john"),
            ("Acts of the Apostles", "acts"),
            ],
        [
            ("General Epistle of James", "james"),
            ("1st Epistle General of Peter", "1pet"),
            ("2nd General Epistle of Peter", "2pet"),
            ("1st Epistle General of John", "1john"),
            ("2nd Epistle General of John", "2john"),
            ("3rd Epistle General of John", "3john"),
            ("General Epistle of Jude", "jude"),
            ],
        [
            ("Epistle of St Paul to Romans", "rom"),
            ("1st Epistle of St Paul to Corinthians", "1cor"),
            ("2nd Epistle of St Paul to Corinthians", "2cor"),
            ("Epistle of St Paul to Galatians", "gal"),
            ("Epistle of St Paul to Ephesians", "ephes"),
            ("Epistle of St Paul to Philippians", "phil"),
            ("Epistle of St Paul to Colossians", "col"),
            ("1st Epistle of St Paul Thessalonians", "1thess"),
            ("2nd Epistle of St Paul Thessalonians", "2thess"),
            ("1st Epistle of St Paul to Timothy", "1tim"),
            ("2nd Epistle of St Paul to Timothy", "2tim"),
            ("Epistle of St Paul to Titus", "tit"),
            ("Epistle of St Paul to Philemon", "philem"),
            ("Epistle of St Paul to Hebrews", "heb"),
            ],
        [
            ("Revelation of St John the Devine", "rev")
        ]
    ]
    
    static let shared = NewTestamentModel()
    
    func getTitle() -> String {
        return Translate.s("New Testament")
    }
    
    func getSections() -> [String] {
        return ["Евангелия и Деяния", "Соборные Послания", "Послания св. Апостола Павла", "Откровение св. Ап. Иоанна Богослова"]
    }
    
    func getItems(_ section: Int) -> [String] {
        return NewTestamentModel.data[section].map { return $0.0 }
    }
    
    func getNumChapters(_ index: IndexPath) -> Int {
        return Db.numberOfChapters(NewTestamentModel.data[index.section][index.row].1)
    }
    
    func getVC(index: IndexPath, chapter: Int) -> UIViewController {
        let code =  NewTestamentModel.data[index.section][index.row].1
        let vc = UIViewController.named("Scripture") as! Scripture
        vc.code = .chapter(code, chapter+1)
        
        return vc
    }
    
}

