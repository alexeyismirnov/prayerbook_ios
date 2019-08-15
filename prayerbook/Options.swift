//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

extension Notification.Name {
    public static let optionsSavedNotification = Notification.Name("OPTIONS_SAVED")
}

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
        
        UITableViewCell.appearance().backgroundColor =  UIColor.white.withAlphaComponent(0.5)

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
        
        let button = UIBarButtonItem(title: Translate.s("Done"), style: .plain, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = button
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

        if indexPath.section == 1 || indexPath.section == 2 {
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: indexPath.section)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: indexPath.section)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
            cell.accessoryType = .checkmark
            
        } else if indexPath.section == 3 {
            if indexPath.row == 0 {
                Theme.set(.Default)
                
                prefs.removeObject(forKey: "theme")
                prefs.synchronize()
                
                NotificationCenter.default.post(name: .themeChangedNotification, object: nil)

                self.dismiss(animated: false, completion: {})
                
            } else {
                /*
                var width, height : CGFloat
                
                if (UIDevice.current.userInterfaceIdiom == .phone) {
                    width = 300
                    height = 300
                    
                } else {
                    width = 500
                    height = 500
                }
                
                let container = UIViewController.named("Palette") as! Palette
                container.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
                container.delegate = self
                
                modalSheet = NAModalSheet(viewController: container, presentationStyle: .fadeInCentered)
                modalSheet.setThemeUsingPrimaryColor(.flatSand, with: .contrast)
                
                modalSheet.disableBlurredBackground = true
                modalSheet.cornerRadiusWhenCentered = 10
                modalSheet.delegate = self
                modalSheet.adjustContentSize(CGSize(width: width, height: height), animated: false)
                
                modalSheet.present(completion: {})
 */
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return Translate.s("Language")
            
        } else if section == 2 {
            return Translate.s("Fasting type")
            
        } else if section == 3 {
            return Translate.s("Background color")
        
        } else if section == 4 {
            return Translate.s("(C) 2017 Brotherhood of Sts Apostoles Peter and Paul, Hong Kong. This app contains information from ponomar.net and orthodox.cn")
        }
        
        return ""
    }

    @IBAction func done(_ sender: AnyObject) {
        var cell : UITableViewCell
        
        cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 2)) as UITableViewCell
        let fasting = (cell.accessoryType == .checkmark) ? 0 : 1
        
        cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
        let lang = (cell.accessoryType == .checkmark) ? "en" : "cn"
        
        Translate.language = lang
        
        prefs.set(lang, forKey: "language")
        prefs.set(fasting, forKey: "fastingLevel")
        prefs.synchronize()
        
        NotificationCenter.default.post(name: .optionsSavedNotification, object: nil)

        dismiss(animated: true, completion: nil)
    }
    
    func doneWithColor(_ color: UIColor) {
        /*
        modalSheet.dismiss(completion: {
            Theme.set(.Chameleon(color: color))
            
            self.prefs.set(color, forKey: "theme")
            self.prefs.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: themeChangedNotification), object: nil)
            self.dismiss(animated: false, completion: {})
        })
 */
    }

}
