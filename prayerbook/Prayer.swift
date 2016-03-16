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
    let prefs = NSUserDefaults(suiteName: groupId)!
    var fontSize: Int = 0
    var index:Int!
    var code:String!
    var name:String!
    
    func reload() {
        let filename = String(format: "prayer_%@_%d_%@.html", code, index, Translate.language)
        let bundleName = NSBundle.mainBundle().pathForResource(filename, ofType: nil)
        var txt:String! = try? String(contentsOfFile: bundleName!, encoding: NSUTF8StringEncoding)
        
        fontSize = prefs.integerForKey("fontSize")
        txt = txt.stringByReplacingOccurrencesOfString("FONTSIZE", withString: "\(fontSize)px")
        
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
            let readings = Scripture.getPericope(readingStr, decorated: false)
            
            for (i, (title, content)) in readings.enumerate() {
                txt = txt.stringByReplacingOccurrencesOfString(
                    String(format:"TITLE%d", (i+1)),
                    withString: title.string)

                txt = txt.stringByReplacingOccurrencesOfString(
                    String(format:"READING%d", (i+1)),
                    withString: content.string)

            }
            
        }
        
        let button_zoom_in = UIBarButtonItem(image: UIImage(named: "zoom_in"), style: .Plain, target: self, action: "zoom_in")
        let button_zoom_out = UIBarButtonItem(image: UIImage(named: "zoom_out"), style: .Plain, target: self, action: "zoom_out")
        
        button_zoom_in.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_zoom_out, button_zoom_in]
        
        webView.paginationBreakingMode = UIWebPaginationBreakingMode.Page
        webView.paginationMode = UIWebPaginationMode.LeftToRight
        webView.scrollView.pagingEnabled = true
        webView.scrollView.bounces = false
        
        webView.loadHTMLString(txt, baseURL: NSURL())
        title = Translate.s(name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)
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

}
