//
//  Library.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/26/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class Library: UITableViewController {
    var code:String = "Library"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var button_options = UIBarButtonItem(image: UIImage(named: "options"), style: .Plain, target: self, action: "showOptions")
        navigationItem.rightBarButtonItems = [button_options]
    }
    
    func showOptions() {
        var vc = storyboard!.instantiateViewControllerWithIdentifier("Options") as! Options
        let nav = UINavigationController(rootViewController: vc)
        vc.delegate = self
        
        navigationController?.presentViewController(nav, animated: true, completion: {})
    }

    // MARK: Table view data source

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if (code == "Library") {
            var vc = storyboard.instantiateViewControllerWithIdentifier("Library") as! Library
            vc.title = NewTestament[indexPath.row].0
            vc.code = NewTestament[indexPath.row].1
            navigationController?.pushViewController(vc, animated: true)

        } else {
            var vc = storyboard.instantiateViewControllerWithIdentifier("Scripture") as! Scripture
            vc.code = .Chapter(code, indexPath.row+1)
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return nil
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (code == "Library") ? NewTestament.count-3 :Db.numberOfChapters(code)
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
        
        cell!.textLabel!.text = (code == "Library") ?  NewTestament[indexPath.row].0 : "Chapter \(indexPath.row+1)"
        
        return cell!
    }

}

