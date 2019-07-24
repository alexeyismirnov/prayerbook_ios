//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

@objc class Translate: NSObject {    

    fileprivate static var dict = [String:String]()
    static var defaultLanguage = "en"
    static var locale  = Locale(identifier: "en")
    static var files = [String]()
    
    static var language:String = defaultLanguage {
        didSet {
            locale = Locale(identifier: (language == "cn") ? "zh_CN" : language)
            
            dict = [:]

            if language == defaultLanguage {
                return
            }
            
            for (_, file) in files.enumerated() {
                dict += NSDictionary(contentsOfFile: file) as! [String: String]
            }
        }
    }
    
    static func s(_ str : String) -> String {
        return dict[str] ?? str
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
