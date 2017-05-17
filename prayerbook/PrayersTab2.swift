//
//  GroupPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/3/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class PrayersTab2: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tab_index: NSNumber!
    @IBOutlet weak var tableView: UITableView!
    
    var entries = [[String]]()
    var titles = ["Eucharist", "Prayers"]
    var sections = [ ["communion"], ["daily", "group"] ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: -30, left: 0, bottom: 0, right: 0)
        
        automaticallyAdjustsScrollViewInsets = false
        navigationController?.makeTransparent()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadTheme), name: NSNotification.Name(rawValue: themeChangedNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)
        
        reloadTheme()
    }

    func reloadTheme() {
        if let bgColor = Theme.mainColor {
            view.backgroundColor =  bgColor
            
        } else {
            view.backgroundColor = UIColor(patternImage: UIImage(background: "bg3.jpg", inView: view))
        }
        
        reload()
    }

    func reload() {
        let bundle = Bundle.main.path(forResource: "prayers", ofType: "plist")
        let table = NSDictionary(contentsOfFile: bundle!) as! [String:[String]]
        
        entries=[]
        for (_, code) in sections[tab_index as! Int].enumerated() {
            entries.append(table[code]!)
        }
        
        title = Translate.s(titles[tab_index as! Int])
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Prayer" {
            let view = segue.destination as! Prayer
            let index = tableView.indexPathForSelectedRow as IndexPath!
            view.index = index?.row
            view.code = sections[tab_index as! Int][(index?.section)!]
            view.name = entries[(index?.section)!][(index?.row)!]
        }
    }
    
    // MARK: Table view data source
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let view = UIViewController.named("Prayer") as! Prayer
        
        view.index = indexPath.row
        view.code = sections[tab_index as! Int][indexPath.section]
        view.name = entries[indexPath.section][indexPath.row]
        
        navigationController?.pushViewController(view, animated: true)
        
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.textLabel?.textColor = Theme.textColor
        headerView.textLabel?.text="qqq"
        headerView.contentView.backgroundColor = UIColor.clear
        headerView.backgroundView?.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TextCell"
        
        var newCell  = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TextCell
        if newCell == nil {
            newCell = TextCell(style: UITableViewCellStyle.default, reuseIdentifier: TextCell.cellId)
        }
        
        newCell!.backgroundColor = .clear
        newCell!.title.textColor =  Theme.textColor
        newCell!.title.text = Translate.s(entries[indexPath.section][indexPath.row])
        return newCell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAt: indexPath)
        return calculateHeightForCell(cell)
    }
    
    func calculateHeightForCell(_ cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRect(x: 0, y: 0, width: tableView.frame.width, height: cell.bounds.height)
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }
    
    
}
