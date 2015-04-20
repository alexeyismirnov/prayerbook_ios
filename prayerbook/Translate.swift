//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

struct Translate {
    private static var dict : NSDictionary?
    static var defaultLanguage = "en"
    static var locale  = NSLocale(localeIdentifier: "en")
    
    static var language:String = defaultLanguage {
        didSet {
            locale = NSLocale(localeIdentifier: (language == "en") ? "en" : "zh_CN")
            
            if language == defaultLanguage {
                return
            }
            
            let bundle = NSBundle.mainBundle().pathForResource("trans_\(language)", ofType: "plist")
            dict = NSDictionary(contentsOfFile: bundle!)
            
        }
    }
    
    static func s(str : String) -> String {
        if language == defaultLanguage {
            return str
        }
        
        if let trans_str = dict?.valueForKey(str) as? String  {
            return trans_str
        } else {
            return str
        }
    }
    
    static func tableViewStrings(code: String) -> [String] {
        let bundle = NSBundle.mainBundle().pathForResource("index_\(language)", ofType: "plist")
        let table = NSDictionary(contentsOfFile: bundle!)
        
        if let trans_table = table?.objectForKey(code) as? [String] {
            return trans_table
        } else {
            return []
        }
    }
    
}
