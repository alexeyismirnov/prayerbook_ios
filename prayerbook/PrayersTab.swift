//
//  GroupPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/3/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class PrayersTab: UITableViewController {

    var entries = [[String]]()
    
    var tab_index: NSNumber!
    var titles = ["Eucharist", "Prayers"]
    var sections = [ ["communion"], ["daily", "group"] ]
    
    func reload() {
        let bundle = Bundle.main.path(forResource: "prayers", ofType: "plist")
        let table = NSDictionary(contentsOfFile: bundle!) as! [String:[String]]
        
        entries=[]
        for (_, code) in sections[tab_index as Int].enumerated() {
            entries.append(table[code]!)
        }
        
        title = Translate.s(titles[tab_index as Int])
        
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .plain, target: self, action: #selector(PrayersTab.showOptions))
        navigationItem.rightBarButtonItems = [button_options]
        
        NotificationCenter.default.addObserver(self, selector: #selector(PrayersTab.reload), name: NSNotification.Name(rawValue: optionsSavedNotification), object: nil)
        reload()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Prayer" {
            let view = segue.destination as! Prayer
            let index = self.tableView.indexPathForSelectedRow as IndexPath!
            view.index = index?.row
            view.code = sections[tab_index as Int][(index?.section)!]
            view.name = entries[(index?.section)!][(index?.row)!]
        }
    }
    
    func showOptions() {
        let vc = storyboard!.instantiateViewController(withIdentifier: "Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        
        navigationController?.present(nav, animated: true, completion: {})
    }
    
    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return entries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TextCell"
        
        var newCell  = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? TextCell
        if newCell == nil {
            newCell = TextCell(style: UITableViewCellStyle.default, reuseIdentifier: TextCell.cellId)
        }
        
        newCell!.title.textColor =  UIColor.black
        newCell!.title.text = Translate.s(entries[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row])
        return newCell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
