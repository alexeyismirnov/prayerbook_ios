//
//  Scripture.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite

enum ScriptureDisplay {
    case Chapter(String, Int)
    case Pericope(String)
}

class Scripture: UIViewController {

    var code: ScriptureDisplay = .Chapter("", 0)
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var backButton = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "closeView")
        navigationItem.leftBarButtonItem = backButton
        
        switch code {
        case let ScriptureDisplay.Chapter(name, chapter):
            showChapter(name, chapter)
            break
        case let ScriptureDisplay.Pericope(str):
            showPericope(str)
            break
        }
    }

    override func viewDidAppear(animated: Bool) {
        textView.setContentOffset(CGPointZero, animated: false)
    }
    
    func formatLine(verse: Int, _ content : String) -> NSMutableAttributedString {
        var text : NSMutableAttributedString? = nil
        text = text + ("\(verse) ", UIColor.redColor())
        text = text + (content, UIColor.blackColor())
        text = text + "\n"

        text!.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(18),
            range: NSMakeRange(0, text!.length))
        
        return text!
    }
    
    func showPericope(str: String) {
        title = "Daily reading"
        var text : NSMutableAttributedString? = nil
        
        var pericope = split(str) { $0 == " " }

        for (var i=0; i<pericope.count; i+=2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercaseString
            let bookTuple = NewTestament.filter { $0.1 == fileName }
            
            var centerStyle = NSMutableParagraphStyle()
            centerStyle.alignment = .Center
            
            var bookName = NSMutableAttributedString(
                    string: bookTuple[0].0 + " " + pericope[i+1],
                attributes: [NSParagraphStyleAttributeName: centerStyle,
                                       NSFontAttributeName: UIFont.boldSystemFontOfSize(18) ])
            
            text = text + bookName + "\n\n"
            
            var arr2 = pericope[i+1].componentsSeparatedByString(",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                var arr3 = segment.componentsSeparatedByString("-")
                for offset in arr3 {
                    var arr4 = offset.componentsSeparatedByString(":")
                    
                    if arr4.count == 1 {
                        range += [ (chapter, arr4[0].toInt()!) ]
                        
                    } else {
                        chapter = arr4[0].toInt()!
                        range += [ (chapter, arr4[1].toInt()!) ]
                    }
                }
                
                if range.count == 1 {
                    for line in Db.book(fileName).filter(Db.chapter == range[0].0 && Db.verse == range[0].1) {
                        text = text + formatLine(line[Db.verse], line[Db.text])
                    }
                    
                } else if range[0].0 != range[1].0 {
                    for line in Db.book(fileName).filter(Db.chapter == range[0].0 && Db.verse >= range[0].1) {
                        text = text + formatLine(line[Db.verse], line[Db.text])
                    }

                    for line in Db.book(fileName).filter(Db.chapter == range[1].0 && Db.verse <= range[1].1) {
                        text = text + formatLine(line[Db.verse], line[Db.text])
                    }

                } else {
                    for line in Db.book(fileName).filter(Db.chapter == range[0].0 && Db.verse >= range[0].1 && Db.verse <= range[1].1) {
                        text = text + formatLine(line[Db.verse], line[Db.text])
                    }
                }
            }
            
            text = text + "\n"
        }

        textView.attributedText =  text
    }
    
    func showChapter(name: String, _ chapter: Int) {
        title = "Chapter \(chapter)"

        var text : NSMutableAttributedString? = nil

        for line in Db.book(name).filter(Db.chapter == chapter) {
            text = text + formatLine(line[Db.verse], line[Db.text])
        }
        
        textView.attributedText =  text
    }
    
    func closeView() {
        navigationController?.popViewControllerAnimated(true)
    }

}
