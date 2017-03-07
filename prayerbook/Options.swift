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
    
    let prefs = UserDefaults(suiteName: groupId)!
    var lastSelected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Translate.s("Options")
        
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: prefs.integer(forKey: "fastingLevel"), section: 0)) as UITableViewCell
        
        cell.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section != 0 {
            return;
        }
        
        var cell: UITableViewCell
        
        cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as UITableViewCell
        cell.accessoryType = .none

        cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 0)) as UITableViewCell
        cell.accessoryType = .none

        cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
        cell.accessoryType = .checkmark

    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Fasting type")
        } else {
            return Translate.s("(C) 2017 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
    }

    @IBAction func done(_ sender: AnyObject) {
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as UITableViewCell
        let fasting = (cell.accessoryType == .checkmark) ? 0 : 1
        
        prefs.set(fasting, forKey: "fastingLevel")
        prefs.synchronize()

        NotificationCenter.default.post(name: Notification.Name(rawValue: optionsSavedNotification), object: nil)
        dismiss(animated: true, completion: nil)
    }

}
