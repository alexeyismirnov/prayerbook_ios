//
//  GroupPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/3/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class ListOfPrayers: UITableViewController {

    var titles: [String] = []
    var prayer_type: String!
    
    func reload() {
        titles = Translate.tableViewStrings(prayer_type)
        self.tableView.reloadData()
    }
    
    func optionsSaved(params: NSNotification) {
        self.reload()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var prayer_type: AnyObject! = self.valueForKey("prayer_type")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionsSaved:", name: optionsSavedNotification, object: nil)
        
        self.reload()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            var view = segue.destinationViewController as Prayer
            var index = self.tableView.indexPathForSelectedRow();
            view.index = index!.row
            view.code = prayer_type
        }
    }
    
    // MARK: Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PrayerCell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if newCell == nil {
            newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        newCell!.textLabel!.text = titles[indexPath.row]
        return newCell!
    }

}
