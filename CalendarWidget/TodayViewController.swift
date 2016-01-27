//
//  TodayViewController.swift
//  CalendarWidget
//
//  Created by Alexey Smirnov on 1/18/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var buttonRight: UIButton!
    @IBOutlet weak var buttonLeft: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var currentDate: NSDate = {
        return NSDateComponents(date: NSDate()).toDate()
    }()
    
    var formatter: NSDateFormatter = {
        var formatter = NSDateFormatter()
        formatter.dateStyle = .ShortStyle
        formatter.timeStyle = .NoStyle
        formatter.dateFormat = "LLLL yyyy"
        return formatter
    }()
    
    let prefs = NSUserDefaults(suiteName: "group.rlc.ponomar")!
    
    var calendarDelegate: CalendarGridDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        let arrowLeft = UIImage(named: "fat-left")?.imageWithRenderingMode(.AlwaysTemplate)
        buttonLeft.imageView?.tintColor = UIColor.whiteColor()
        buttonLeft.setImage(arrowLeft, forState: .Normal)
        
        let arrowRight = UIImage(named: "fat-right")?.imageWithRenderingMode(.AlwaysTemplate)
        buttonRight.imageView?.tintColor = UIColor.whiteColor()
        buttonRight.setImage(arrowRight, forState: .Normal)

        calendarDelegate = CalendarGridDelegate()
        calendarDelegate.containerType = .TodayExtension

        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        let upperBorder = CALayer();
        upperBorder.backgroundColor = UIColor.lightGrayColor().CGColor;
        upperBorder.frame = CGRectMake(0, CGRectGetHeight(collectionView.frame)-2, CGRectGetWidth(collectionView.frame), 2.0);
        collectionView.layer.addSublayer(upperBorder)
        
        if let language = prefs.objectForKey("language") as? String {
            Translate.language = language
        }
        
        calendarDelegate.generateLabels(view)

        refresh()
    }

    func refresh() {
        formatter.locale = NSLocale(localeIdentifier: (Translate.language == "en") ? "en" : "ru")

        monthLabel.text = formatter.stringFromDate(currentDate)
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
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
}
