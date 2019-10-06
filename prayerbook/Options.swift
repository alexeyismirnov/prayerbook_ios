//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class Options: UITableViewController {
    
    let prefs = AppGroup.prefs!
    var lastSelected: IndexPath?
    
    let labels : [(IndexPath, String)] = [
        (IndexPath(row:0,section:2), "Laymen fasting"),
        (IndexPath(row:1,section:2), "Monastic fasting"),
        (IndexPath(row:0,section:3), "Default"),
        (IndexPath(row:1,section:3), "Choose color...")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(done(tapGestureRecognizer:)))
        
        let doneLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        doneLabel.text = Translate.s("Done")
        doneLabel.textColor = .red
        doneLabel.font = UIFont.boldSystemFont(ofSize: 18)
        doneLabel.isUserInteractionEnabled = true
        doneLabel.addGestureRecognizer(tap1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneLabel)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: .themeChangedNotification, object: nil)

        view.backgroundColor = UIColor.clear
        tableView.backgroundView = UIImageView(image: UIImage(background: "church.jpg", inView: view))
        
        navigationController?.makeTransparent()
        navigationController?.navigationBar.tintColor = UIColor.red
        
        let languageCell = self.tableView(tableView, cellForRowAt: IndexPath(row: Translate.language == "en" ? 0 : 1, section: 1)) as UITableViewCell
        languageCell.accessoryType = .checkmark

        let fastingCell = self.tableView(tableView, cellForRowAt: IndexPath(row: prefs.integer(forKey: "fastingLevel"), section: 2)) as UITableViewCell
        fastingCell.accessoryType = .checkmark
        
        for (ind, label) in labels {
            let cell = self.tableView(tableView, cellForRowAt: ind) as UITableViewCell
            cell.textLabel?.text = Translate.s(label)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UITableViewCell.appearance().backgroundColor =  UIColor.white.withAlphaComponent(0.5)
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UITableViewCell.appearance().backgroundColor =  UIColor.white.withAlphaComponent(0)
        super.viewDidDisappear(animated)
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
        var cell: UITableViewCell

        if indexPath.section == 1  {
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
            cell.accessoryType = .checkmark
            
            let lang = indexPath.row == 0 ? "en" : "cn"
            Translate.language = lang
            
            prefs.set(lang, forKey: "language")
          
        } else if indexPath.section == 2 {
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 2)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
            cell.accessoryType = .checkmark
            
            let fasting = indexPath.row
            FastingModel.fastingLevel = FastingLevel(rawValue:fasting)
            
            prefs.set(fasting, forKey: "fastingLevel")

        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                Theme.set(.Default)
                
                prefs.removeObject(forKey: "theme")
                prefs.synchronize()
                
                NotificationCenter.default.post(name: .themeChangedNotification, object: nil)

                self.dismiss(animated: false, completion: {})
                
            } else {
                let bundle = Bundle(identifier: "com.rlc.swift-toolkit")
                let container = UIViewController.named("Palette", bundle: bundle) as! Palette
                showPopup(container)
            }
            
        }
        
        prefs.synchronize()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return Translate.s("Language")
            
        } else if section == 2 {
            return Translate.s("Fasting type")
            
        } else if section == 3 {
            return Translate.s("Background color")
        
        } else if section == 4 {
            return Translate.s("(C) 2019 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong. This app contains information from ponomar.net and orthodox.cn")
        }
        
        return ""
    }

    @objc func done(tapGestureRecognizer: UITapGestureRecognizer) {
        NotificationCenter.default.post(name: .themeChangedNotification, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateTheme(_ notification: NSNotification) {
        guard let color = notification.userInfo?["color"] as? UIColor else { return }
        
        UIViewController.popup.dismiss({
            self.prefs.set(color, forKey: "theme")
            self.prefs.synchronize()
            
            self.dismiss(animated: false, completion: {})
        })
    }
}
