//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class Scripture: UITableViewController {

    var titles: [String] = ["Matthew", "Mark", "Luke", "John"]
    var chapters: [String] = ["Chapter 1", "Chapter 2", "Chapter 3"]
    
    var selectionIndex : Int!
    var code = "Library"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = code
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var dest = segue.destinationViewController as Scripture
        dest.code = titles[selectionIndex]
    }
    
    // MARK: Table view data source

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        selectionIndex = indexPath.row
        return indexPath
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (code == "Library") ? titles.count : chapters.count
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (code == "Library") ? "New Testament" : nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ScriptureCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        cell!.textLabel.text = (code == "Library") ?  titles[indexPath.row] : chapters[indexPath.row]
        
        return cell!
    }

}

