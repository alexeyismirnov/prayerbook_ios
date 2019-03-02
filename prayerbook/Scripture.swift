//
//  Scripture.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 01.12.14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

enum ScriptureDisplay {
    case chapter(String, Int)
    case pericope(String)
}

class Scripture: UIViewController {
    var fontSize: CGFloat!
    var code: ScriptureDisplay = .chapter("", 0)
    let prefs = UserDefaults(suiteName: groupId)!

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let toolkit = Bundle(identifier: "com.rlc.swift-toolkit")
        
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: .optionsSavedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)

        let backButton = UIBarButtonItem(image: UIImage(named: "close", in: toolkit, compatibleWith: nil), style: .plain, target: self, action: #selector(closeView))
        navigationItem.leftBarButtonItem = backButton
        
        let button_zoom_in = CustomBarButton(image: UIImage(named: "zoom_in", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(Scripture.zoom_in))
        let button_zoom_out = CustomBarButton(image: UIImage(named: "zoom_out", in: toolkit, compatibleWith: nil)!, target: self, btnHandler: #selector(Scripture.zoom_out))

        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        fontSize = CGFloat(prefs.integer(forKey: "fontSize"))

        reloadTheme()
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        }
        
        reload()
    }

    
    @objc func zoom_in() {
        fontSize += 2
        prefs.set(Int(fontSize), forKey: "fontSize")
        prefs.synchronize()
        
        reload()
    }
    
    @objc func zoom_out() {
        fontSize -= 2
        prefs.set(Int(fontSize), forKey: "fontSize")
        prefs.synchronize()

        reload()
    }
    
    @objc func reload() {
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
        super.viewDidAppear(animated)
        textView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func showPericope(_ str: String)  {
        title = ""
        
        let pericope = Scripture.getPericope(str.trimmingCharacters(in: CharacterSet.whitespaces), decorated: true, fontSize: fontSize)
        
        var text = NSAttributedString()

        for (title, content) in pericope {
            text +=  title + "\n\n" + content + "\n"
        }
        
        textView.attributedText =  text
    }
    
    func showChapter(_ name: String, _ chapter: Int) {
        var text = NSAttributedString()
        
        let header = (name == "ps") ? "Кафизма %@" : Translate.s("Chapter %@")
        let title = String(format: header, Translate.stringFromNumber(chapter))
            .colored(with: Theme.textColor).boldFont(ofSize: fontSize).centered
        
        text += title + "\n\n"

        for line in Db.book(name, whereExpr: "chapter=\(chapter)") {
            let row  = Scripture.decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
            text = text + row
        }
        
        textView.attributedText =  text
    }
    
    @objc func closeView() {
        let _ = navigationController?.popViewController(animated: true)
    }
    
    static func decorateLine(_ verse:Int64, _ content:String, _ fontSize:CGFloat) -> NSAttributedString {
        var text = NSAttributedString()
        text += "\(verse) ".colored(with: UIColor.red) + content.colored(with: Theme.textColor) + "\n"
        
        return text.systemFont(ofSize: fontSize)
    }
    
    static func getPericope(_ str: String, decorated: Bool, fontSize: CGFloat = 14.0) -> [(NSAttributedString, NSAttributedString)] {
        var result = [(NSAttributedString, NSAttributedString)]()
        
        var pericope = str.split { $0 == " " }.map { String($0) }
        
        for i in stride(from: 0, to: pericope.count-1, by: 2) {
            var chapter: Int = 0
            
            let fileName = pericope[i].lowercased()
            let bookTuple = (NewTestament+OldTestament).flatMap { $0.filter { $0.1 == fileName } }
            
            var bookName = NSAttributedString()
            var text = NSAttributedString()
            
            if decorated {
                bookName = (Translate.s(bookTuple[0].0) + " " + pericope[i+1]).colored(with: Theme.textColor).boldFont(ofSize: fontSize).centered
                
            } else {
                bookName = NSAttributedString(string: Translate.s(bookTuple[0].0))
            }
            
            let arr2 = pericope[i+1].components(separatedBy: ",")
            
            for segment in arr2 {
                var range: [(Int, Int)]  = []
                
                let arr3 = segment.components(separatedBy: "-")
                for offset in arr3 {
                    var arr4 = offset.components(separatedBy: ":")
                    
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
                            text += decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize )
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                } else if range[0].0 != range[1].0 {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1)") {
                        if decorated {
                            text += decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                    for chap in range[0].0+1 ..< range[1].0 {
                        for line in Db.book(fileName, whereExpr: "chapter=\(chap)") {
                            if decorated {
                                text += decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                            } else {
                                text += (line["text"] as! String) + " "
                            }
                        }
                    }
                    
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[1].0) AND verse<=\(range[1].1)") {
                        if decorated {
                            text += decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                    
                } else {
                    for line in Db.book(fileName, whereExpr: "chapter=\(range[0].0) AND verse>=\(range[0].1) AND verse<=\(range[1].1)") {
                        if decorated {
                            text += decorateLine(line["verse"] as! Int64, line["text"] as! String, fontSize)
                        } else {
                            text += (line["text"] as! String) + " "
                        }
                    }
                }
            }
            
            text += "\n"
            result += [(bookName, text)]
        }
        
        return result
    }


}

