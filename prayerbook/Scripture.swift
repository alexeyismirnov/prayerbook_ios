//
//  Scripture.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

enum ScriptureDisplay {
    case Chapter(String, Int)
    case Pericope(String)
}

class Scripture: UIViewController {

    var fontSize: Int = 0
    var code: ScriptureDisplay = .Chapter("", 0)
    let prefs = NSUserDefaults(suiteName: groupId)!

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)

        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .Plain, target: self, action: "closeView")
        navigationItem.leftBarButtonItem = backButton
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in"), style: .Plain, target: self, action: "zoom_in")
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out"), style: .Plain, target: self, action: "zoom_out")

        button_zoom_in.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        fontSize = prefs.integerForKey("fontSize")

        reload()
    }
    
    func zoom_in() {
        fontSize += 2
        prefs.setObject(fontSize, forKey: "fontSize")
        prefs.synchronize()
        
        reload()
    }
    
    func zoom_out() {
        fontSize -= 2
        prefs.setObject(fontSize, forKey: "fontSize")
        prefs.synchronize()

        reload()
    }
    
    func reload() {
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
    
    func showPericope(str: String)  {
        title = ""
        
        var text : NSMutableAttributedString? = nil
        let pericope = Scripture.getPericope(str.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()), decorated: true, fontSize: fontSize)
        
        for (title, content) in pericope {
            text = text + title + "\n\n"
            text = text + content + "\n"
        }
        
        textView.attributedText =  text
    }
    
    func showChapter(name: String, _ chapter: Int) {
        title = String(format: Translate.s("Chapter %@"), Translate.stringFromNumber(chapter))

        var text : NSMutableAttributedString? = nil

        for line in Db.book(name, whereExpr: "chapter=\(chapter)") {
            let row  = Scripture.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
            text = text + row
        }
        
        textView.attributedText =  text
    }
    
    func closeView() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    static func decorateLine(verse:Int64, _ content:String, _ fontSize:Int) -> NSMutableAttributedString {
        var text : NSMutableAttributedString? = nil
        text = text + ("\(verse) ", UIColor.redColor())
        text = text + (content, UIColor.blackColor())
        text = text + "\n"
        
        text!.addAttribute(NSFontAttributeName,
            value: UIFont.systemFontOfSize(CGFloat(fontSize)),
            range: NSMakeRange(0, text!.length))
        
        return text!
    }
    
    static func getPericope(str: String, decorated: Bool, fontSize: Int = 0) -> [(NSMutableAttributedString, NSMutableAttributedString)] {
        var result = [(NSMutableAttributedString, NSMutableAttributedString)]()
        
        var pericope = str.characters.split { $0 == " " }.map { String($0) }
        
        for (var i=0; i<pericope.count; i+=2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercaseString
            let bookTuple = (NewTestament+OldTestament).filter { $0.1 == fileName }
            
            let centerStyle = NSMutableParagraphStyle()
            centerStyle.alignment = .Center
            
            var bookName:NSMutableAttributedString
            var text : NSMutableAttributedString? = nil
            
            if decorated {
                bookName = NSMutableAttributedString(
                    string: Translate.s(bookTuple[0].0) + " " + pericope[i+1],
                    attributes: [NSParagraphStyleAttributeName: centerStyle,
                        NSFontAttributeName: UIFont.boldSystemFontOfSize(CGFloat(fontSize)) ])
                
            } else {
                bookName = NSMutableAttributedString(string: Translate.s(bookTuple[0].0))
            }
            
            let arr2 = pericope[i+1].componentsSeparatedByString(",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                let arr3 = segment.componentsSeparatedByString("-")
                for offset in arr3 {
                    var arr4 = offset.componentsSeparatedByString(":")
                    
                    if arr4.count == 1 {
                        range += [ (chapter, Int(arr4[0])!) ]
                        
                    } else {
                        chapter = Int(arr4[0])!
                        range += [ (chapter, Int(arr4[1])!) ]
                    }
                }
                
                if range.count == 1 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse=\(range[0].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize )
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                } else if range[0].0 != range[1].0 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                    for chap in range[0].0+1 ..< range[1].0 {
                        for line in Db.book(fileName, whereExpr: "chapter=\(chap)") {
                            if decorated {
                                text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                            } else {
                                text = text + (line["text"] as! String) + " "
                            }
                        }
                    }
                    
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[1].0) AND verse<=\(range[1].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                    
                } else {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1) AND verse<=\(range[1].1)") {
                        if decorated {
                            text = text + decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text = text + (line["text"] as! String) + " "
                        }
                    }
                }
            }
            
            text = text + "\n"
            result += [(bookName, text!)]
        }
        
        return result
    }


}
