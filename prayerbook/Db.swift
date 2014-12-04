//
//  Db.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import Foundation
import SQLite
import UIKit

let NewTestament: [(String, String)] = [
    ("Gospel of St Matthew", "matthew"),
    ("Gospel of St Mark", "mark"),
    ("Gospel of St Luke", "luke"),
    ("Gospel of St John", "john"),
    ("Acts of the Apostles", "acts"),
    ("Epistle of St Paul to Romans", ""),
    ("1st Epistle of St Paul to Corinthians", ""),
    ("2nd Epistle of St Paul to Corinthians", ""),
    ("Epistle of St Paul to Galatians", ""),
    ("Epistle of St Paul to Ephesians", ""),
    ("Epistle of St Paul to Philippians", ""),
    ("Epistle of St Paul to Colossians", ""),
    ("1st Epistle of St Paul Thessalonians", ""),
    ("2nd Epistle of St Paul Thessalonians", ""),
    ("1st Epistle of St Paul to Timothy", ""),
    ("2nd Epistle of St Paul to Timothy", ""),
    ("Epistle of St Paul to Titus", ""),
    ("Epistle of St Paul to Philemon", ""),
    ("Epistle of St Paul to Hebrews", ""),
    ("General Epistle of James", ""),
    ("1st Epistle General of Peter", ""),
    ("2nd General Epistle of Peter", ""),
    ("1st Epistle General of John", ""),
    ("2nd Epistle General of John", ""),
    ("3rd Epistle General of John", ""),
    ("General Epistle of Jude", ""),
    ("Revelation of St John the Devine", "")
]


struct Db {

    static let chapter = Expression<Int>("chapter")
    static let verse = Expression<Int>("verse")
    static let text = Expression<String>("text")

    static func book(name: String) -> Query {
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString, ofType: "sqlite")!
        let db = Database(path, readonly: true)
        return db["scripture"]
    }
}
