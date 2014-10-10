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
    
    var currentDay: NSDateComponents!
    let calendar = NSCalendar.currentCalendar()
    var formatter = NSDateFormatter()

    var titles: [String] = []
    
    func reload() {
        if Translate.language == "en" {
            formatter.locale = NSLocale(localeIdentifier: "en")
        } else {
            formatter.locale = NSLocale(localeIdentifier: "zh_CN")
        }
        
        dateLabel.text = formatter.stringFromDate(calendar.dateFromComponents(currentDay)!)

        titles = Translate.tableViewStrings("daily")
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FeastCalendar.getFeastDescription(2014)
        
        addBarButtons()
        addRoundedBorder(foodButton)
        addLayoutConstraints()
        
        currentDay = calendar.components(.CalendarUnitDay | .CalendarUnitMonth | .CalendarUnitYear, fromDate: NSDate())
        
        formatter.dateStyle = .FullStyle
        formatter.timeStyle = .NoStyle
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "optionsSaved:", name: optionsSavedNotification, object: nil)
        
        self.reload()
    }

    
    @IBAction func showFastingInfo(sender: AnyObject) {
        var fastingInfo = FastingViewController(nibName: "FastingViewController", bundle: nil)
        var modal = NAModalSheet(viewController: fastingInfo, presentationStyle: .FadeInCentered)
        
        modal.disableBlurredBackground = true
        modal.cornerRadiusWhenCentered = 10
        modal.delegate = self
        
        fastingInfo.modal = modal
        fastingInfo.type = .Vegetarian
        fastingInfo.fastTitle = "Vegetarian"
        
        modal.presentWithCompletion({})
    }
    
    func optionsSaved(params: NSNotification) {
        self.reload()
    }
    
    func prev_day() {
        currentDay.day--;
        reload()
    }
    
    func next_day() {
        currentDay.day++
        reload()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Prayer" {
            var view = segue.destinationViewController as Prayer
            var index = self.tableView.indexPathForSelectedRow();
            view.index = index!.row
            view.code = "daily"

        } else if segue.identifier == "Calendar" {
            let nav = segue.destinationViewController as UINavigationController
            let dest = nav.viewControllers[0] as CalendarViewController
            dest.delegate = self
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
    
}
