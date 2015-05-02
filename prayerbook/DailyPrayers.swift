//
//  DailyPrayers.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class DailyPrayers: UIViewController, UITableViewDelegate, UITableViewDataSource, NAModalSheetDelegate {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
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

    var titles: [String] = []
    var readings: [String] = []
    var fasting: (FastingType, String) = (.Vegetarian, "")
    var foodIcon: [FastingType: String] = [
        .NoFast:        "meat",
        .Vegetarian:    "vegetables",
        .FishAllowed:   "fish",
        .FastFree:      "cupcake",
        .Cheesefare:    "cheese",
    ]
    
    func reload() {
        formatter.locale = Translate.locale
        dateLabel.text = formatter.stringFromDate(currentDate)

        /*
        var description = Cal.getDayDescription(currentDate)
        if let weekDescription = Cal.getWeekDescription(currentDate) {
            description = description + (weekDescription, UIColor.grayColor()) + "\n"
        }
            
        description = description + (Cal.getToneDescription(currentDate), UIColor.grayColor())

        infoLabel.attributedText  = description
        
        if let _fasting = Cal.getFastingDescription(currentDate) {
            fasting = _fasting
            foodLabel.text = fasting.1
            let allowedFood = foodIcon[fasting.0]!
            foodButton.setImage(UIImage(named: "food-\(allowedFood)"), forState: .Normal)
        }
        
        titles = Translate.tableViewStrings("daily")
        readings = DailyReading.getDailyReading(currentDate)
*/
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBarButtons()
        addRoundedBorder(foodButton)
        addLayoutConstraints()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reload", name: optionsSavedNotification, object: nil)
        
        reload()
    }

    @IBAction func showFastingInfo(sender: AnyObject) {
        var fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
        var modal = NAModalSheet(viewController: fastingInfo, presentationStyle: .FadeInCentered)
        
        modal.disableBlurredBackground = true
        modal.cornerRadiusWhenCentered = 10
        modal.delegate = self
        
        fastingInfo.modal = modal
        fastingInfo.type =  fasting.0
        fastingInfo.fastTitle = fasting.1
        
        modal.presentWithCompletion({})
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Calendar" {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.viewControllers[0] as! CalendarViewController
            dest.delegate = self
        }
    }
    
    // MARK: Table view data source
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if indexPath.section == 0 && readings.count > 0 {
            var vc = storyboard.instantiateViewControllerWithIdentifier("Scripture") as! Scripture
            vc.code = .Pericope(readings[indexPath.row])
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.section == 1 {
            var vc = storyboard.instantiateViewControllerWithIdentifier("Prayer") as! Prayer
            vc.index = indexPath.row
            vc.code = "daily"
            navigationController?.pushViewController(vc, animated: true)
        }
        
        return nil
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return (readings.count == 0) ? 1: readings.count
        } else {
            return titles.count
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Daily Scripture"
        } else {
            return "Daily Prayers"
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        
        var newCell  = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! UITableViewCell!
        if newCell == nil {
            newCell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        if (indexPath.section == 0) {
            if readings.count == 0 {
                newCell.textLabel!.text = "No reading"
            } else {
                newCell.textLabel!.text = join(" ", split(readings[indexPath.row]) { $0 == " " })
            }
            
        } else {
            newCell.textLabel!.text = titles[indexPath.row]
        }
        
        return newCell
    }
    
    // MARK: NAModalSheetDelegate
    
    func modalSheetTouchedOutsideContent(sheet: NAModalSheet!) {
        sheet.dismissWithCompletion({})
    }
    
    func modalSheetShouldAutorotate(sheet: NAModalSheet!) -> Bool {
        return shouldAutorotate()
    }
    
    func modalSheetSupportedInterfaceOrientations(sheet: NAModalSheet!) -> UInt {
        return UInt(supportedInterfaceOrientations())
    }

    // MARK: private stuff
    
    private func addLayoutConstraints() {
        let leftConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 10)
        
        self.view.addConstraint(leftConstraint)
        
        let rightConstraint = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.Trailing, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -10)
        
        self.view.addConstraint(rightConstraint)
    }
    
    private func addRoundedBorder(button: UIButton!) {
        let color = self.view.tintColor
        button.layer.borderColor = color.CGColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 10
        button.setTitleColor(color, forState: UIControlState.Normal)
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
