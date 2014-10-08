//
//  DailyPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class DailyPrayers: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    var titles: [String] = []
    
    func reload() {
        titles = Translate.tableViewStrings("daily")
        self.tableView.reloadData()
    }
    
    func optionsSaved(params: NSNotification) {
        self.reload()
    }

    func addRoundedBorder(button: UIButton!) {
        let color = self.view.tintColor
        button.layer.borderColor = color.CGColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.setTitleColor(color, forState: UIControlState.Normal)
    }
    
    func prev_day() {
        NSLog("prev_day")
    }
    
    func next_day() {
        NSLog("next_day")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var arrow_left_image = UIImage(named: "arrow-left")
        var arrow_right_image = UIImage(named: "arrow-right")

        var button_left = UIBarButtonItem(image: arrow_left_image, style: .Plain, target: self, action: "prev_day")

        var button_right = UIBarButtonItem(image: arrow_right_image, style: .Plain, target: self, action: "next_day")
        
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.rightBarButtonItems = [button_right, button_left]
        
        addRoundedBorder(foodButton)
        
        let leftConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
        
        self.view.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -10)
        
        self.view.addConstraint(rightConstraint)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionsSaved:", name: optionsSavedNotification, object: nil)

        self.reload()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            var view = segue.destinationViewController as Prayer
            var index = self.tableView.indexPathForSelectedRow();
            view.index = index!.row
            view.code = "daily"
        }
    }
    
    // MARK: Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return titles.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Daily Gospel"
        } else {
            return "Daily Prayers"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell!
        if newCell == nil {
            newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        if (indexPath.section == 0) {
            newCell.textLabel!.text = "Luke 2:3-4"
        } else {
            newCell.textLabel!.text = titles[indexPath.row]
        }
        
        return newCell
    }

    
    
}
