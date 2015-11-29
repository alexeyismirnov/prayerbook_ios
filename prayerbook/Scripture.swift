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

    var code: ScriptureDisplay = .Chapter("", 0)
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)

        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .Plain, target: self, action: "closeView")
        navigationItem.leftBarButtonItem = backButton
        
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .Plain, target: self, action: "showOptions")
        navigationItem.rightBarButtonItems = [button_options]
        
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
    
    func showOptions() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }

    func showPericope(str: String)  {
        title = Translate.s("Gospel of the day")
        
        var text : NSMutableAttributedString? = nil
        let pericope = DailyReading.getPericope(str, decorated: true)
        
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
            let row  = DailyReading.decorateLine(line["verse"] as! Int64, line["text"] as! String)
            text = text + row
        }
        
        textView.attributedText =  text
    }
    
    func closeView() {
        navigationController?.popViewControllerAnimated(true)
    }

}
