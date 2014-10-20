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
    
    func reload() {
        let filename = String(format: "prayer_%@_%d_%@.html", code, index, Translate.language)
        let bundleName = NSBundle.mainBundle().pathForResource(filename, ofType: nil)
        
        var txt:String! = String(contentsOfFile: bundleName!, encoding: NSUTF8StringEncoding, error: nil)

        let prefs = NSUserDefaults.standardUserDefaults()
        let fontSize = prefs.integerForKey("fontSize")
        
        txt = txt.stringByReplacingOccurrencesOfString("FONTSIZE", withString: "\(fontSize)pt")
        
        self.webView.paginationBreakingMode = UIWebPaginationBreakingMode.Page
        self.webView.paginationMode = UIWebPaginationMode.LeftToRight
        self.webView.scrollView.pagingEnabled = true
        self.webView.scrollView.bounces = false
        
        self.webView.loadHTMLString(txt, baseURL: NSURL())
        let titles = Translate.tableViewStrings(code)
        self.title = titles[index]
    }
    
    func optionsSaved(params: NSNotification) {
        self.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionsSaved:", name: optionsSavedNotification, object: nil)
        
        self.reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Options" {
            let nav = segue.destinationViewController as UINavigationController
            let dest = nav.viewControllers[0] as Options
            dest.delegate = self
        }
    }

}
