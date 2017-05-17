//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

var optionsSavedNotification  = "OPTIONS_SAVED"
let themeChangedNotification  = "THEME_CHANGED"
let dateChangedNotification = "DATE_CHANGED"

class Options: UITableViewController {
    let prefs = UserDefaults(suiteName: groupId)!

    @IBOutlet weak var laymen_label: UILabel!
    @IBOutlet weak var monastic_label: UILabel!
    @IBOutlet weak var laymen_lent: UITableViewCell!
    @IBOutlet weak var monastic_lent: UITableViewCell!
    @IBOutlet weak var lang_en: UITableViewCell!
    @IBOutlet weak var lang_cn: UITableViewCell!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Translate.s("Options")
        cancelButton.title = Translate.s("Cancel")
        doneButton.title = Translate.s("Done")
        
        laymen_label.text = Translate.s("Laymen fasting")
        monastic_label.text = Translate.s("Monastic fasting")
        
        if Translate.language == "en" {
            lang_en.accessoryType = .checkmark;
            lang_en.setSelected(true, animated: true)
            
        } else {
            lang_cn.accessoryType = .checkmark;
            lang_cn.setSelected(true, animated: true)
        }
        
        if prefs.integer(forKey: "fastingLevel") == 0 {
            laymen_lent.accessoryType = .checkmark
            laymen_lent.setSelected(true, animated: true)
            
        } else {
            monastic_lent.accessoryType = .checkmark
            monastic_lent.setSelected(true, animated: true)
        }
        
     }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section ==  0 {
            lang_en.accessoryType = .none
            lang_en.isSelected = false

            lang_cn.accessoryType = .none
            lang_cn.isSelected = false
            
        } else if indexPath.section ==  1 {
            laymen_lent.accessoryType = .none
            laymen_lent.isSelected = false

            monastic_lent.accessoryType = .none
            monastic_lent.isSelected = false
        }

        let cell: UITableViewCell! = self.tableView.cellForRow(at: indexPath)
        cell.accessoryType = .checkmark
        cell.isSelected = true
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Language")
        
        } else if section == 1 {
            return Translate.s("Fasting type")
        
        } else {
            return Translate.s("(C) 2017 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong. This app contains information from ponomar.net and orthodox.cn")
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        let lang = (lang_en.accessoryType == .checkmark) ? "en" : "cn"
        let fasting = (laymen_lent.accessoryType == .checkmark) ? 0 : 1

        Translate.language = lang

        prefs.set(lang, forKey: "language")
        prefs.set(fasting, forKey: "fastingLevel")

        prefs.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: optionsSavedNotification), object: nil)
        dismiss(animated: true, completion: nil)
    }

}
