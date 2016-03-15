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
    
    let prefs = NSUserDefaults(suiteName: groupId)!
    var lastSelected: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Translate.s("Options")
        
        let cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: prefs.integerForKey("fastingLevel"), inSection: 0)) as UITableViewCell
        
        cell.accessoryType = .Checkmark
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section != 0 {
            return;
        }
        
        var cell: UITableViewCell
        
        cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as UITableViewCell
        cell.accessoryType = .None

        cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0)) as UITableViewCell
        cell.accessoryType = .None

        cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as UITableViewCell
        cell.accessoryType = .Checkmark

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Fasting type")
        } else {
            return Translate.s("(C) 2016 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
    }

    @IBAction func done(sender: AnyObject) {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) as UITableViewCell
        let fasting = (cell.accessoryType == .Checkmark) ? 0 : 1
        
        prefs.setObject(fasting, forKey: "fastingLevel")
        prefs.synchronize()

        NSNotificationCenter.defaultCenter().postNotificationName(optionsSavedNotification, object: nil)
        dismissViewControllerAnimated(true, completion: nil)
    }

}
