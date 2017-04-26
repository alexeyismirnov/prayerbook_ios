//
//  Options.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

let optionsSavedNotification  = "OPTIONS_SAVED"
let themeChangedNotification  = "THEME_CHANGED"

class Options: UITableViewController, NAModalSheetDelegate {
    
    let prefs = UserDefaults(suiteName: groupId)!
    var lastSelected: IndexPath?
    var modalSheet: NAModalSheet!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = UIImageView(image: UIImage(background: "church.jpg", inView: view))
        
        navigationController?.makeTransparent()
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
        if indexPath.section == 1 {
            var cell: UITableViewCell
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 1, section: 1)) as UITableViewCell
            cell.accessoryType = .none
            
            cell = self.tableView(tableView, cellForRowAt: indexPath) as UITableViewCell
            cell.accessoryType = .checkmark
            
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                Theme.set(.Default)
                
                prefs.removeObject(forKey: "theme")
                prefs.synchronize()
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: themeChangedNotification), object: nil)
                self.dismiss(animated: false, completion: {})
                
            } else {
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
            }
            
        } else if indexPath.section == 3 {
            let vc = UIViewController.named("RTFDocument") as! RTFDocument
            vc.docTitle = "История храма"
            vc.docFilename = "church_history"
            
            self.navigationController?.pushViewController(vc, animated: true)

        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return Translate.s("Fasting type")
            
        } else if section == 2 {
            return Translate.s("Background color")
        
        } else if section == 3 {
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
    
    func doneWithColor(_ color: UIColor) {
        modalSheet.dismiss(completion: {
            Theme.set(.Chameleon(color: color))
            
            self.prefs.set(color, forKey: "theme")
            self.prefs.synchronize()
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: themeChangedNotification), object: nil)
            self.dismiss(animated: false, completion: {})
        })
    }
    
    // MARK: NAModalSheetDelegate
    
    func modalSheetTouchedOutsideContent(_ sheet: NAModalSheet!) {
        sheet.dismiss(completion: {})
    }
    
    func modalSheetShouldAutorotate(_ sheet: NAModalSheet!) -> Bool {
        return shouldAutorotate
    }
    
    func modalSheetSupportedInterfaceOrientations(_ sheet: NAModalSheet!) -> UInt {
        return supportedInterfaceOrientations.rawValue
    }


}
