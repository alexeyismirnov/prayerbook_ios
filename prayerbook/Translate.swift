//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

var groupId = "group.rlc.ponomar-ru"

@objc class Translate: NSObject {    
    static let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)!

    fileprivate static var dict = [String:String]()
    static var defaultLanguage = "en"
    static var locale  = Locale(identifier: "en")
    static var files = [String]()
    
    static var language:String = defaultLanguage {
        didSet {
            locale = Locale(identifier: "ru")
            
            if language == defaultLanguage {
                return
            }
            
            dict = [:]
            
            for (_, file) in files.enumerated() {
                let filename = "\(file)_\(language).plist"
                let dst = groupURL.appendingPathComponent(filename)
                let newDict = NSDictionary(contentsOfFile: dst.path) as! [String: String]
                
                dict += newDict
            }
        }
    }
    
    static func s(_ str : String) -> String {
        if language == defaultLanguage {
            return str
        }
        
        if let trans_str = dict[str] as String!  {
            return trans_str
        } else {
            return str
        }
    }
    
    static func stringFromNumber(_ num : Int) -> String {
        if language == defaultLanguage {
            return String(num)

        } else {
            let formatter = NumberFormatter()
            formatter.locale = locale
            
            if language == "cn" {
                formatter.numberStyle = .spellOut
            }
            
            return formatter.string(from: NSNumber(integerLiteral: num))!
        }
    }
    
    static func readings(_ reading : String) -> String {
        var reading = reading
        if language == defaultLanguage {
            return reading
        }
        
        let bundle = Bundle.main.path(forResource: "Reading_\(language)", ofType: "plist")
        let books = NSDictionary(contentsOfFile: bundle!) as! [String:String]
        
        for (key, value) in books {
            reading = reading.replacingOccurrences(of: key, with: value)
        }
        
        return reading
    }
}
