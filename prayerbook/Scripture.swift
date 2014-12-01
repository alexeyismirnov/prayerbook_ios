//
//  Scripture.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import SQLite

struct ScriptureRange {
    var name: String
    var fromChapter: Int
    var fromVerse: Int
    var toChapter: Int
    var toVerse: Int
}

enum ScriptureDisplay {
    case Chapter(String, Int)
    case Range(ScriptureRange)
    case Sequence(Array<ScriptureRange>)
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
            title = "\(name), \(chapter)"
            showChapter(name, chapter)
            break
        case let ScriptureDisplay.Range(r):
            title = "\(r.name) \(r.fromChapter):\(r.fromVerse)-\(r.toChapter):\(r.toVerse)"
            break
        case let ScriptureDisplay.Sequence(_):
            title = ""
            break
        }
    }

    override func viewDidAppear(animated: Bool) {
        textView.setContentOffset(CGPointZero, animated: false)
    }
    
    func showChapter(name: String, _ chapter: Int) {
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
