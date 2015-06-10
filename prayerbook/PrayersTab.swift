//
//  GroupPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/3/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class PrayersTab: UITableViewController {

    var titles = [[String]]()
    
    var tab_index: NSNumber!
    var sections = [ ["communion"], ["daily", "group"] ]
    
    func reload() {
        
        let bundle = NSBundle.mainBundle().pathForResource("prayers", ofType: "plist")
        let table = NSDictionary(contentsOfFile: bundle!) as! [String:[String]]
        
        titles=[]
        for (index, code) in enumerate(sections[tab_index as Int]) {
            titles.append(table[code]!)
        }
        
        self.tableView.reloadData()
    }
    
    func optionsSaved(params: NSNotification) {
        self.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionsSaved:", name: optionsSavedNotification, object: nil)
        self.reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            var view = segue.destinationViewController as! Prayer
            var index = self.tableView.indexPathForSelectedRow() as NSIndexPath!
            view.index = index.row
            view.code = sections[tab_index as Int][index.section]
            view.name = titles[index.section][index.row]
        }
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return titles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PrayerCell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if newCell == nil {
            newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        newCell!.textLabel!.text = Translate.s(titles[indexPath.section][indexPath.row])
        return newCell!
    }

}
