//
//  CalendarContainer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/20/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarContainer: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let cal: NSCalendar = {
        let c = NSCalendar.currentCalendar()
        c.locale = NSLocale(localeIdentifier: (Translate.language == "en") ? "en" : "ru")
        return c
    }()

    var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = NSLocale(localeIdentifier: (Translate.language == "en") ? "en" : "ru")
        return formatter
    }()
    
    var currentDate: NSDate = ChurchCalendar.currentDate
    var calendarDelegate: CalendarGridDelegate!
    var delegate: DailyTab!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarDelegate = CalendarGridDelegate()
        calendarDelegate.containerType = .MainApp
        
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("doneWithDate:"))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)

        let dayLabel = formatter.shortWeekdaySymbols as [String]
        
        for index in cal.firstWeekday...7 {
            if let label = self.view.viewWithTag(index-cal.firstWeekday+1) as? UILabel {
                label.text = dayLabel[index-1]
            }
        }

        if cal.firstWeekday > 1 {
            for index in 1...cal.firstWeekday-1 {
                if let label = self.view.viewWithTag(8-cal.firstWeekday+index) as? UILabel {
                    label.text = dayLabel[index-1]
                }
            }
        }
        
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        let upperBorder = CALayer();
        upperBorder.backgroundColor = UIColor.lightGrayColor().CGColor;
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), 2.0);
        collectionView.layer.addSublayer(upperBorder)
    }
    
    func doneWithDate(recognizer: UITapGestureRecognizer) {
        let loc = recognizer.locationInView(collectionView)
        var curDate: NSDate? = nil
        
        if let
            path = collectionView.indexPathForItemAtPoint(loc),
            cell = collectionView.cellForItemAtIndexPath(path) as? CalendarViewTextCell,
            dayNum = Int(cell.dateLabel.text!) {
                curDate = NSDate(dayNum, currentDate.month, currentDate.year)
        }
        
        delegate.hideCalendar(curDate)
    }
    
    func refresh() {
        title = formatter.stringFromDate(currentDate)
        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()
    }

    @IBAction func prevMonth(sender: AnyObject) {
        currentDate = currentDate - 1.months
        refresh()
    }
    
    @IBAction func nextMonth(sender: AnyObject) {
        currentDate = currentDate + 1.months
        refresh()
    }
    

}
