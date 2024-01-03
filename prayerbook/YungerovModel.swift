//
//  YungerovModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 8/29/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

// https://stackoverflow.com/a/39474725/995049
extension Int {
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
}

class YungerovModel : EbookModel {
    public init() {
        super.init("yungerov")
    }
    
    override func getContent(at pos: BookPosition) -> Any? {
        guard let index = pos.index else { return nil }
        let ps = Int.parse(from: items[index.section]![index.row])!

        var result = ""
        
        let verses_yu =  try! db.selectAll("SELECT text FROM content_yu WHERE psalm=$0 ORDER BY verse",
                                      parameters: [ps]) { $0.stringValueAtIndex(0) ?? "" }
        
        let verses_cs =  try! db.selectAll("SELECT text FROM content_cs WHERE psalm=$0 ORDER BY verse",
                                      parameters: [ps]) { $0.stringValueAtIndex(0) ?? "" }
        
        for (index, var text) in verses_yu.enumerated() {
            let pattern = "comment_(\\d+)"
            let regex = try! NSRegularExpression(pattern: pattern)
            
            if index > 0 {
                result += "<span class='rubric'>\(index)</span>&nbsp;"
            }
            
            if regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).count > 0 {
                let text2 = NSMutableString(string: text)
                
                regex.replaceMatches(in: text2, options: .reportProgress, range: NSRange(location: 0,length: text2.length), withTemplate: "&nbsp;&nbsp;<a href=\"comment://$1\"><img class=\"icon\"/></a>&nbsp;&nbsp;")
                
                text = String(text2)
            }
            
            let text_cs = verses_cs[safe: index]!
            
            result += text + "<br/>" + "<span class='subtitle'>\(text_cs)</span><p>"
        }
        
        return result
    }
    
}

