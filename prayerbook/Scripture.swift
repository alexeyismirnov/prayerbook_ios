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
    
    func showPericope(str: String) {
        title = "Daily reading"
        var text : NSMutableAttributedString? = nil
        
//      "Acts 1:1-8 John 1:1-17"

        var pericope = str.componentsSeparatedByString(" ")
        for (var i=0; i<pericope.count; i+=2) {
            var chapter: Int = 0
            
            text = text + pericope[i]
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
                
                text = text + " " + "\(range[0].0):\(range[0].1) - \(range[1].0):\(range[1].1)"
            }
            
            text = text + "\n"
            
        }

        textView.attributedText =  text
        textView.font = UIFont.systemFontOfSize(18)
    }
    
    func showChapter(name: String, _ chapter: Int) {
        title = "\(name), \(chapter)"

        var text : NSMutableAttributedString? = nil

        for line in Db.book(name).filter(Db.chapter == chapter) {
            text = text + ("\(line[Db.verse]) ", UIColor.redColor())
            text = text + (line[Db.text], UIColor.blackColor())
            text = text + "\n"
        }
        
        textView.attributedText =  text
        textView.font = UIFont.systemFontOfSize(18)
    }
    
    func closeView() {
        navigationController?.popViewControllerAnimated(true)
    }

}
