//
//  DailyTab.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class DailyTab: UITableViewController {
    
    var fasting: (FastingType, String) = (.Vegetarian, "")
    var foodIcon: [FastingType: String] = [
        .NoFast:        "meat",
        .Vegetarian:    "vegetables",
        .FishAllowed:   "fish",
        .FastFree:      "cupcake",
        .Cheesefare:    "cheese",
    ]
    
    var readings = [String]()
    var dayDescription = [(FeastType, String)]()

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)

        reload()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return count(dayDescription)+2
        case 1:
            return count(readings)
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return ""
        } else {
            return "Daily Reading"
        }
    }

    func getCell<T: ConfigurableCell>() -> T {
        if let newCell  = tableView.dequeueReusableCellWithIdentifier(T.cellId) as? T {
            return newCell
            
        } else {
            return T(style: UITableViewCellStyle.Default, reuseIdentifier: T.cellId)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                var cell: TextDetailsCell = getCell()
                cell.title.text = formatter.stringFromDate(currentDate)

                var subtitle:String = ""
                
                if let weekDescription = Cal.getWeekDescription(currentDate) {
                    subtitle = weekDescription
                }
                
                if let toneDescription = Cal.getToneDescription(currentDate) {
                    if count(subtitle) > 0 {
                        subtitle += ". "
                    }
                    subtitle += toneDescription
                }
                
                cell.subtitle.text = subtitle
                return cell

            case 1:
                var cell: ImageCell  = getCell()
                cell.title.text = fasting.1
                cell.icon.image = UIImage(named: "food-\(foodIcon[fasting.0]!)")
                return cell
                
            default:
                var cell: TextCell = getCell()
                cell.title.textColor = (dayDescription[indexPath.row-2].0 == FeastType.NoSign) ?  UIColor.blackColor() : UIColor.redColor()
                cell.title.text = dayDescription[indexPath.row-2].1
                return cell
            }
        
        } else if indexPath.section == 1 {
//            var cell: TextCell = getCell()
            var cell: TextDetailsCell = getCell()

            cell.title.textColor = UIColor.blackColor()
            cell.title.text = readings[indexPath.row]
            cell.subtitle.text = ""
            return cell
        }
        
        var cell: TextCell = getCell()
        return cell

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell : UITableViewCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)
        return calculateHeightForCell(cell)
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
        
        dayDescription = Cal.getDayDescription(currentDate)
        readings = DailyReading.getDailyReading(currentDate)
        fasting = Cal.getFastingDescription(currentDate)

        tableView.reloadData()
    }

    func addBarButtons() {
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