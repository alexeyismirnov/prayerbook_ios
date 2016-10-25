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
    weak var delegate: UIViewController!

    @IBOutlet weak var lang_en: UITableViewCell!
    @IBOutlet weak var lang_cn: UITableViewCell!
    @IBOutlet weak var fontSizeSlider: UISlider!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = Translate.s("Options")
        cancelButton.title = Translate.s("Cancel")
        doneButton.title = Translate.s("Done")
        
        if Translate.language == "en" {
            lastSelected = IndexPath(row: 0, section: 0)
            lang_en.accessoryType = UITableViewCellAccessoryType.checkmark;
            lang_en.setSelected(true, animated: true)
            
        } else {
            lastSelected = IndexPath(row: 1, section: 0)
            lang_cn.accessoryType = UITableViewCellAccessoryType.checkmark;
            lang_cn.setSelected(true, animated: true)
            
        }
        
        let fontSize = prefs.integer(forKey: "fontSize")
        fontSizeSlider.value = Float(fontSize)
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            fontSizeSlider.minimumValue = 8
            fontSizeSlider.maximumValue = 20
            
        } else {
            fontSizeSlider.minimumValue = 10
            fontSizeSlider.maximumValue = 30
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if lastSelected == indexPath || (indexPath as NSIndexPath).section == 1 {
            return
        }
        
        let cell1: UITableViewCell! = self.tableView.cellForRow(at: lastSelected!)
        cell1.accessoryType = .none
        cell1.isSelected = false
        
        let cell2: UITableViewCell! = self.tableView.cellForRow(at: indexPath)
        cell2.accessoryType = .checkmark
        cell2.isSelected = true
        
        lastSelected = indexPath
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return Translate.s("Language")
        } else {
            return Translate.s("(C) 2015 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong. This app contains information from ponomar.net and orthodox.cn")
        }
    }
    
    @IBAction func cancel(_ sender: AnyObject) {
        delegate.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: AnyObject) {
        let lang = (lang_en.accessoryType == .checkmark) ? "en" : "cn"

        prefs.set(lang, forKey: "language")
        Translate.language = lang
        prefs.set(Int(fontSizeSlider.value), forKey: "fontSize")
        prefs.synchronize()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: optionsSavedNotification), object: nil)
        delegate.dismiss(animated: true, completion: nil)
    }

}
