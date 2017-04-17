//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

let optionsSavedNotification  = "OPTIONS_SAVED"

class Options: UITableViewController {
    
    weak var delegate : DailyTab!
    let prefs = UserDefaults(suiteName: groupId)!
    var lastSelected: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "church.jpg")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        view.backgroundColor = UIColor(patternImage: image)

        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        navigationController?.navigationBar.tintColor = UIColor.red
        
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: prefs.integer(forKey: "fastingLevel"), section: 1)) as UITableViewCell
        cell.accessoryType = .checkmark
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        
        if (section > 0) {
            headerView.layer.opacity = 0.5
            headerView.contentView.backgroundColor = UIColor.white
            headerView.backgroundView?.backgroundColor = UIColor.white
            
        } else {
            headerView.contentView.backgroundColor = UIColor.clear
            headerView.backgroundView?.backgroundColor = UIColor.clear
            
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            delegate.showHistory()

        } else if indexPath.section == 1 {
            var cell: UITableViewCell
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
            cell.accessoryType = .checkmark
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return Translate.s("Fasting type")
            
        } else if section == 2 {
            return Translate.s("Brotherhood of Sts Apostoles Peter and Paul, Hong Kong.")
        }
        
        return ""
    }

    @IBAction func done(_ sender: AnyObject) {
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
        let fasting = (cell.accessoryType == .checkmark) ? 0 : 1
        
        prefs.set(fasting, forKey: "fastingLevel")
        prefs.synchronize()

        NotificationCenter.default.post(name: Notification.Name(rawValue: optionsSavedNotification), object: nil)
        dismiss(animated: true, completion: nil)
    }

}
