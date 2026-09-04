//
//  Translate.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

extension Array {
    mutating func mapInPlace(_ transform: (Element) -> Element) {
        self = map(transform)
    }
}

public class Translate: NSObject {
    fileprivate static var dict = [String:[String:String]]()
    
    static public var defaultLanguage = "en"
    static public var locale  = Locale(identifier: "en")
    static public var files = [String]() {
        didSet {
            dict = [:]

            for file in files {
                let lang = file.components(separatedBy: "_").last!
                
                if !dict.keys.contains(lang) {
                    dict[lang] = [String:String]()
                }
                
                let path = AppGroup.url.appendingPathComponent("\(file).plist").path
                if let loaded = NSDictionary(contentsOfFile: path) as? [String: String] {
                    dict[lang]! += loaded
                }
            }
        }
    }
    
    static public var language:String = defaultLanguage {
        didSet {
            switch (language) {
            case "cn":
                locale = Locale(identifier:"zh_CN")
                break
            case "hk":
                locale = Locale(identifier:"zh_HK")
                break
            default:
                locale = Locale(identifier: language)
            }
        }
    }
    
    static public func s(_ str : String, lang: String? = nil) -> String {
        let lang = lang ?? language
        return dict[lang]?[str] ?? str
    }
    
    static public func stringFromNumber(_ num : Int) -> String {        
        if language == defaultLanguage {
            return String(num)

        } else {
            let formatter = NumberFormatter()
            formatter.locale = locale
            
            if language == "cn" || language == "hk" {
                formatter.numberStyle = .spellOut
            }
            
            return formatter.string(from: NSNumber(integerLiteral: num))!
        }
    }
    
    static public func readings(_ reading : String) -> String {
        var reading = reading
        if language == defaultLanguage {
            return reading
        }
        
        let bundle = Bundle.main.path(forResource: "trans_reading_\(language)", ofType: "plist")
        let books = NSDictionary(contentsOfFile: bundle!) as! [String:String]
        
        for (key, value) in books {
            reading = reading.replacingOccurrences(of: key, with: value)
        }
        
        return reading
    }
}
