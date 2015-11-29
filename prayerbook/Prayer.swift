//
//  Prayer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class Prayer: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var index:Int!
    var code:String!
    var name:String!
    
    func reload() {
        let filename = String(format: "prayer_%@_%d_%@.html", code, index, Translate.language)
        let bundleName = NSBundle.mainBundle().pathForResource(filename, ofType: nil)
        
        var txt:String! = try? String(contentsOfFile: bundleName!, encoding: NSUTF8StringEncoding)

        let prefs = NSUserDefaults.standardUserDefaults()
        let fontSize = prefs.integerForKey("fontSize")
        
        txt = txt.stringByReplacingOccurrencesOfString("FONTSIZE", withString: "\(fontSize)pt")
        
        if (code == "typica") {
            let tone = Cal.getTone(Cal.currentDate)
            txt = txt.stringByReplacingOccurrencesOfString("GLAS", withString: Translate.stringFromNumber(tone!))
            
            let bundleTypica = NSBundle.mainBundle().pathForResource(String(format: "typica_%d", tone!), ofType: "plist")
            let fragments = NSArray(contentsOfFile: bundleTypica!) as! [[String:String]]

            for (i, fragment) in fragments.enumerate() {
                txt = txt.stringByReplacingOccurrencesOfString(
                    String(format:"FRAGMENT%d!", i),
                    withString: fragment[Translate.language]!)
                
            }
            
            let readingStr = DailyReading.getRegularReading(Cal.currentDate)!
            let readings = DailyReading.getPericope(readingStr, decorated: false)
            
            for (i, (title, content)) in readings.enumerate() {
                txt = txt.stringByReplacingOccurrencesOfString(
                    String(format:"TITLE%d", (i+1)),
                    withString: title.string)

                txt = txt.stringByReplacingOccurrencesOfString(
                    String(format:"READING%d", (i+1)),
                    withString: content.string)

            }
            
        }
        
        self.webView.paginationBreakingMode = UIWebPaginationBreakingMode.Page
        self.webView.paginationMode = UIWebPaginationMode.LeftToRight
        self.webView.scrollView.pagingEnabled = true
        self.webView.scrollView.bounces = false
        
        self.webView.loadHTMLString(txt, baseURL: NSURL())
        self.title = Translate.s(name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)
        self.reload()
    }
    

}
