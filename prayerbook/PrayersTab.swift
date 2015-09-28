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
        for (_, code) in sections[tab_index as Int].enumerate() {
            entries.append(table[code]!)
        }
        
        title = Translate.s(titles[tab_index as Int])
        
        self.tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .Plain, target: self, action: "showOptions")
        navigationItem.rightBarButtonItems = [button_options]
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)
        reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            let view = segue.destinationViewController as! Prayer
            let index = self.tableView.indexPathForSelectedRow as NSIndexPath!
            view.index = index.row
            view.code = sections[tab_index as Int][index.section]
            view.name = entries[index.section][index.row]
        }
    }
    
    func showOptions() {
        let vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
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
        let cellIdentifier = "TextCell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? TextCell
        if newCell == nil {
            newCell = TextCell(style: UITableViewCellStyle.Default, reuseIdentifier: TextCell.cellId)
        }
        
        newCell!.title.textColor =  UIColor.blackColor()
        newCell!.title.text = Translate.s(entries[indexPath.section][indexPath.row])
        return newCell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return calculateHeightForCell(cell)
    }
    
    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        let size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return max(size.height+1.0, 40)
    }


}
