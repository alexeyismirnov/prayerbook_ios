//
//  Options2.swift
//  ponomar
//
//  Created by Alexey Smirnov on 12/1/2024.
//  Copyright © 2024 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public class Options: UIViewController, ResizableTableViewCells {
    var toolkit : Bundle!
    let prefs = AppGroup.prefs!

    public var tableView: UITableView!
    var button_close : CustomBarButton!
    var fastingLevel: Int!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        toolkit = Bundle(identifier: "swift-toolkit-swift-toolkit-resources")!
        fastingLevel = prefs.integer(forKey: "fastingLevel")
        
        createTableView(style: .grouped)
        configureNavbar()
        
        reloadTheme()
    }
    
    func configureNavbar() {
        navigationController?.makeTransparent()
        
        button_close = CustomBarButton(image: UIImage(named: "close", in: toolkit), style: .plain, target: self, action: #selector(close))
        navigationItem.leftBarButtonItems = [button_close]
    }
    
    @objc func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view, bundle: toolkit))
        }
        
        title = Translate.s("Options")
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: Theme.textColor!]
    }
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 2
            
        case 2:
            return 3
            
        case 3:
            return 2
            
        default:
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return Translate.s("Fasting type")
            
        case 2:
            return Translate.s("Background color")
            
        case 3:
            return "Язык Библии"
            
        default:
            return ""
        }
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                return getTextDetailsCell(title: "Пост для мирян", isChecked: indexPath.row == fastingLevel)

            } else {
                return getTextDetailsCell(title: "Монашеский пост", isChecked: indexPath.row == fastingLevel)

            }

        } else if indexPath.section == 2 {
            let style = prefs.integer(forKey: "style")
            
            switch indexPath.row {
            case 0:
                return getTextDetailsCell(title: "Цвет по умолчанию", isChecked: indexPath.row == style)
                
            case 1:
                return getTextDetailsCell(title: "Светлый", isChecked: indexPath.row == style)

            case 2:
                return getTextDetailsCell(title: "Темный", isChecked: indexPath.row == style)
                
            default: break
            }
            
        } else if indexPath.section == 3 {
            let bibleLang = prefs.integer(forKey: "bibleLang")

            switch indexPath.row {
            case 0:
                return getTextDetailsCell(title: "Церковнославянский", isChecked: indexPath.row == bibleLang)
                
            case 1:
                return getTextDetailsCell(title: "Русский", isChecked: indexPath.row == bibleLang)
                
            default: break
            }
        }
        
        let cell = getSimpleCell("")
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 1 {
            fastingLevel = indexPath.row
            FastingModel.fastingLevel = FastingLevel(rawValue:fastingLevel)
            
            prefs.set(fastingLevel, forKey: "fastingLevel")
            prefs.synchronize()
            
            tableView.reloadData()
            
        } else if indexPath.section == 2 {
            prefs.set(indexPath.row, forKey: "style")
            prefs.synchronize()
            
            let style = AppStyle(rawValue: indexPath.row)!
            Theme.set(style)

            reloadTheme()
            tableView.reloadData()
            
        } else if indexPath.section == 3 {
            prefs.set(indexPath.row, forKey: "bibleLang")
            prefs.synchronize()

            tableView.reloadData()
        }
        
        NotificationCenter.default.post(name: .themeChangedNotification, object: nil)
        
        return nil
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let title = UILabel()
        let content = self.tableView(tableView, titleForHeaderInSection: section)!
        
        if content.count == 0 {
            return nil
        }

        title.numberOfLines = 1
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.textColor = Theme.secondaryColor
        title.text = content
        
        headerView.backgroundColor = UIColor.clear
        headerView.addSubview(title)
        headerView.fullScreen(view: title, marginX: 15, marginY: 5)
        
        return headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let content = self.tableView(tableView, titleForHeaderInSection: section)!
        return content.count == 0 ? 0 : 40
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        let h = calculateHeightForCell(cell)
        
        return  max(h, 35) 
    }
    
}
