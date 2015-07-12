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
        let bundle = NSBundle.mainBundle().pathForResource("prayers", ofType: "plist")
        let table = NSDictionary(contentsOfFile: bundle!) as! [String:[String]]
        
        entries=[]
        for (index, code) in enumerate(sections[tab_index as Int]) {
            entries.append(table[code]!)
        }
        
        title = Translate.s(titles[tab_index as Int])
        
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .Plain, target: self, action: "showOptions")
        navigationItem.rightBarButtonItems = [button_options]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)
        reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            var view = segue.destinationViewController as! Prayer
            var index = self.tableView.indexPathForSelectedRow() as NSIndexPath!
            view.index = index.row
            view.code = sections[tab_index as Int][index.section]
            view.name = entries[index.section][index.row]
        }
    }
    
    func showOptions() {
        var vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return entries.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PrayerCell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if newCell == nil {
            newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        newCell!.textLabel!.text = Translate.s(entries[indexPath.section][indexPath.row])
        return newCell!
    }

}
