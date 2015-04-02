//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class DailyTab: UITableViewController {
    let textCell = "TextCell"
    let imageCell = "ImageCell"
    
    var fasting: (FastingType, String) = (.Vegetarian, "")
    var foodIcon: [FastingType: String] = [
        .NoFast:        "meat",
        .Vegetarian:    "vegetables",
        .FishAllowed:   "fish",
        .FastFree:      "cupcake",
        .Cheesefare:    "cheese",
    ]

    var currentDate: NSDate = {
        // this is done to remove time component from date
        let dateComponents = NSDateComponents(date: NSDate())
        return dateComponents.toDate()
    }()
    
    var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButtons()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    
    func getImageCell() -> ImageCell {
        if let newCell = tableView.dequeueReusableCellWithIdentifier(imageCell) as? ImageCell {
            return newCell

        } else {
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: imageCell) as ImageCell
        }
    }
    
    func getTextCell() -> TextCell {
        if let newCell  = tableView.dequeueReusableCellWithIdentifier(textCell) as? TextCell {
            return newCell
            
        } else {
            return UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: textCell) as TextCell
            
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        NSLog("index \(indexPath.row)")

        switch indexPath.row {
        case 2:
            var newCell  = getImageCell()
            configureImageCell(newCell, indexPath: indexPath)
            return newCell

        default:
            var newCell = getTextCell()
            configureTextCell(newCell, indexPath: indexPath)
            return newCell
        }

    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return ""
        } else {
            return "Daily Scripture"
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
        case 2:
            return heightForImageCell(indexPath)
        default:
            return heightForTextCell(indexPath)
        }
    }
    
    func configureTextCell(cell: TextCell, indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            cell.title.text = "very very very very long long long long long text"
            
        } else {
            cell.title.text = "qq qqq qq qqq qqq qqq qqq qqq qqq very very very very long long long long long text"
            
        }
    }
    
    func configureImageCell(cell: ImageCell!, indexPath:NSIndexPath) {
        
        if let _fasting = Cal.getFastingDescription(currentDate) {
            fasting = _fasting
            let allowedFood = foodIcon[fasting.0]!
            cell.title.text = fasting.1
            cell.icon.image = UIImage(named: "food-\(allowedFood)")
        }
        
    }
    
    func heightForTextCell(indexPath: NSIndexPath) -> CGFloat {
        struct Static {
            static var cell : TextCell!
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.cell = self.getTextCell()
        }
        
        configureTextCell(Static.cell, indexPath: indexPath)
        return calculateHeightForCell(Static.cell)
    }

    func heightForImageCell(indexPath: NSIndexPath) -> CGFloat {
        struct Static {
            static var cell : ImageCell!
            static var onceToken: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.onceToken) {
            Static.cell = self.getImageCell()
        }
        
        configureImageCell(Static.cell, indexPath: indexPath)
        return calculateHeightForCell(Static.cell)
    }

    func calculateHeightForCell(cell: UITableViewCell) -> CGFloat {
        cell.bounds = CGRectMake(0, 0, CGRectGetWidth(tableView.frame), CGRectGetHeight(cell.bounds))
        cell.setNeedsLayout()
        cell.layoutIfNeeded()
        
        var size = cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height+1.0
    }

    // MARK: private stuff
    
    func reload() {
        formatter.locale = Translate.locale
        
        tableView.reloadData()
    }

    private func addBarButtons() {
        var button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "prev_day")
        var button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .Plain, target: self, action: "next_day")
        
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        navigationItem.rightBarButtonItems = [button_right, button_left]
    }

    func prev_day() {
        currentDate = currentDate - 1.days;
        reload()
    }
    
    func next_day() {
        currentDate = currentDate + 1.days;
        reload()
    }

}