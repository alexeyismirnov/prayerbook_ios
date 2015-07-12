//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct Translate {
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
            for (index, file) in enumerate(files) {
                let bundle = NSBundle.mainBundle().pathForResource("\(file)_\(language)", ofType: "plist")
                let newDict = NSDictionary(contentsOfFile: bundle!) as! [String: String]
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
            var formatter = NSNumberFormatter()
            formatter.locale = locale
            
            if language == "cn" {
                formatter.numberStyle = .SpellOutStyle
            }
            return formatter.stringFromNumber(num)!
        }
    }
}
