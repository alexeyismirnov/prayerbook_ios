//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

var groupId = "group.rlc.ponomar"

@objc class Translate: NSObject {    
    static let groupURL = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier(groupId)!

    private static var dict = [String:String]()
    static var defaultLanguage = "en"
    static var locale  = NSLocale(localeIdentifier: "en")
    static var files = [String]()
    
    static var language:String = defaultLanguage {
        didSet {
            locale = NSLocale(localeIdentifier: (language == "en") ? "en" : "zh_CN")
            
            if language == defaultLanguage {
                return
            }
            
            dict = [:]
            for (_, file) in files.enumerate() {
                let filename = "\(file)_\(language).plist"
                let dst = groupURL.URLByAppendingPathComponent(filename)
                let newDict = NSDictionary(contentsOfFile: dst.path!) as! [String: String]
                
                dict += newDict
            }
        }
    }
    
    static func s(str : String) -> String {
        if language == defaultLanguage {
            return str
        }
        
        if let trans_str = dict[str] as String!  {
            return trans_str
        } else {
            return str
        }
    }
    
    static func stringFromNumber(num : Int) -> String {
        if language == defaultLanguage {
            return String(num)

        } else {
            let formatter = NSNumberFormatter()
            formatter.locale = locale
            
            if language == "cn" {
                formatter.numberStyle = .SpellOutStyle
            }
            return formatter.stringFromNumber(num)!
        }
    }
    
    static func readings(var reading : String) -> String {
        if language == defaultLanguage {
            return reading
        }
        
        let bundle = NSBundle.mainBundle().pathForResource("Reading_\(language)", ofType: "plist")
        let books = NSDictionary(contentsOfFile: bundle!) as! [String:String]
        
        for (key, value) in books {
            reading = reading.stringByReplacingOccurrencesOfString(key, withString: value)
        }
        
        return reading
    }
}
