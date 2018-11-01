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
    let prefs = UserDefaults(suiteName: groupId)!
    var popup: PopupController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(done(tapGestureRecognizer:)))
        
        let doneLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 40))
        doneLabel.text = "Закрыть"
        doneLabel.textColor = .red
        doneLabel.font = UIFont.boldSystemFont(ofSize: 18)
        doneLabel.isUserInteractionEnabled = true
        doneLabel.addGestureRecognizer(tap1)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: doneLabel)

        NotificationCenter.default.addObserver(self, selector: #selector(updateTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)

        UITableViewCell.appearance().backgroundColor =  UIColor.white.withAlphaComponent(0.5) 
        
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = UIImageView(image: UIImage(background: "church.jpg", inView: view, bundle: Bundle(identifier: "com.rlc.swift-toolkit")))
        
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
                let bundle = Bundle(identifier: "com.rlc.swift-toolkit")
                let container = UIViewController.named("Palette", bundle: bundle) as! Palette
                
                popup = PopupController
                    .create(self.navigationController!)
                    .customize(
                        [
                            .animation(.fadeIn),
                            .layout(.center),
                            .backgroundStyle(.blackFilter(alpha: 0.7))
                        ]
                )
                
                popup.show(container)
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

    @objc func done(tapGestureRecognizer: UITapGestureRecognizer) {
        let cell = self.tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 1)) as UITableViewCell
        let fasting = (cell.accessoryType == .checkmark) ? 0 : 1
        
        prefs.set(fasting, forKey: "fastingLevel")
        prefs.synchronize()

        NotificationCenter.default.post(name: .optionsSavedNotification, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func updateTheme(_ notification: NSNotification) {
        guard let color = notification.userInfo?["color"] as? UIColor else { return }
        
        popup.dismiss({
            self.prefs.set(color, forKey: "theme")
            self.prefs.synchronize()
            
            self.dismiss(animated: false, completion: {})
        })
    }

}
