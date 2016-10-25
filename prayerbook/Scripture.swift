//
//  Scripture.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

enum ScriptureDisplay {
    case chapter(String, Int)
    case pericope(String)
}

class Scripture: UIViewController {

    var fontSize: Int = 0
    var code: ScriptureDisplay = .chapter("", 0)
    let prefs = UserDefaults(suiteName: groupId)!

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(Scripture.reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)

        let backButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(Scripture.closeView))
        navigationItem.leftBarButtonItem = backButton
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in"), style: .plain, target: self, action: #selector(Scripture.zoom_in))
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out"), style: .plain, target: self, action: #selector(Scripture.zoom_out))

        button_zoom_in.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        fontSize = prefs.integer(forKey: "fontSize")

        reload()
    }
    
    func zoom_in() {
        fontSize += 2
        prefs.set(fontSize, forKey: "fontSize")
        prefs.synchronize()
        
        reload()
    }
    
    func zoom_out() {
        fontSize -= 2
        prefs.set(fontSize, forKey: "fontSize")
        prefs.synchronize()

        reload()
    }
    
    func reload() {
        switch code {
        case let ScriptureDisplay.chapter(name, chapter):
            showChapter(name, chapter)
            break
        case let ScriptureDisplay.pericope(str):
            showPericope(str)
            break
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func showOptions() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.present(nav, animated: true, completion: {})
    }

    func showPericope(_ str: String)  {
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
    
    func showChapter(_ name: String, _ chapter: Int) {
        title = String(format: Translate.s("Chapter %@"), Translate.stringFromNumber(chapter))

        var text : NSMutableAttributedString? = nil

        for line in Db.book(name, whereExpr: "chapter=\(chapter)") {
            let row  = DailyReading.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
            text = text + row
        }
        
        textView.attributedText =  text
    }
    
    func closeView() {
        navigationController?.popViewController(animated: true)
    }

}
