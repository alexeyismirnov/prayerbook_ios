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

struct Db {
    static let chapter = Expression<Int>("chapter")
    static let verse = Expression<Int>("verse")
    static let text = Expression<String>("text")

    static func book(name: String) -> Query {
        let path = NSBundle.mainBundle().pathForResource(name.lowercaseString, ofType: "sqlite")!
        let db = Database(path, readonly: true)
        return db["gospel"]
    }
}
