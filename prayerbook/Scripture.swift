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
    
    func showOptions() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }

    func showPericope(str: String)  {
        title = ""
        //Translate.s("Gospel of the day")
        
        var text : NSMutableAttributedString? = nil
        let pericope = DailyReading.getPericope(str, decorated: true, fontSize: fontSize)
        
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
            let row  = DailyReading.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
            text = text + row
        }
        
        textView.attributedText =  text
    }
    
    func closeView() {
        navigationController?.popViewControllerAnimated(true)
    }

}
