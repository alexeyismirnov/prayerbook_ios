//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

var optionsSavedNotification  = "OPTIONS_SAVED"

class Options: UITableViewController {
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var lastSelected: NSIndexPath?
    weak var delegate: UIViewController!

    @IBOutlet weak var lang_en: UITableViewCell!
    @IBOutlet weak var lang_cn: UITableViewCell!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let language = Translate.language
        self.title = Translate.stringFor("Options")
        cancelButton.title = Translate.stringFor("Cancel")
        doneButton.title = Translate.stringFor("Done")
        
        if language == "en" {
            lastSelected = NSIndexPath(forRow: 0, inSection: 0)
            lang_en.accessoryType = UITableViewCellAccessoryType.Checkmark;
            lang_en.setSelected(true, animated: true)
            
        } else {
            lastSelected = NSIndexPath(forRow: 1, inSection: 0)
            lang_cn.accessoryType = UITableViewCellAccessoryType.Checkmark;
            lang_cn.setSelected(true, animated: true)
            
        }
        
        let fontSize = prefs.integerForKey("fontSize")
        fontSizeSlider.value = Float(fontSize)
        
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            fontSizeSlider.minimumValue = 8
            fontSizeSlider.maximumValue = 20
            
        } else {
            fontSizeSlider.minimumValue = 10
            fontSizeSlider.maximumValue = 30
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if lastSelected == indexPath || indexPath.section == 1 {
            return
        }
        
        var cell1: UITableViewCell! = self.tableView.cellForRowAtIndexPath(lastSelected!)
        cell1.accessoryType = .None
        cell1.selected = false
        
        var cell2: UITableViewCell! = self.tableView.cellForRowAtIndexPath(indexPath)
        cell2.accessoryType = .Checkmark
        cell2.selected = true
        
        lastSelected = indexPath
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.stringFor("Language")
        } else {
            return Translate.stringFor("Font size")
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func done(sender: AnyObject) {
        var lang = (lang_en.accessoryType == .Checkmark) ? "en" : "cn"

        prefs.setObject(lang, forKey: "language")
        Translate.language = lang
        prefs.setInteger(Int(fontSizeSlider.value), forKey: "fontSize")
        prefs.synchronize()
        
        NSNotificationCenter.defaultCenter().postNotificationName(optionsSavedNotification, object: nil)
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }

}
