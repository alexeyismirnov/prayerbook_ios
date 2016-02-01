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
    @IBOutlet weak var saintsLabel: UILabel!
    
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
        
        let recognizer = UITapGestureRecognizer(target: self, action:Selector("tapOnCell:"))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        saintsLabel.attributedText = nil
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
    
    func tapOnCell(recognizer: UITapGestureRecognizer) {
        let loc = recognizer.locationInView(collectionView)
        var curDate: NSDate? = nil
        
        if let
            path = collectionView.indexPathForItemAtPoint(loc),
            cell = collectionView.cellForItemAtIndexPath(path) as? CalendarViewTextCell,
            dayNum = Int(cell.dateLabel.text!) {
                curDate = NSDate(dayNum, currentDate.month, currentDate.year)
                
                let saints = Db.saints(curDate!)
                let dayDescription = Cal.getDayDescription(curDate!)
                let feasts = (saints+dayDescription).sort { $0.0.rawValue > $1.0.rawValue }
                
                let myString = NSMutableAttributedString(string: "")
                
                if let iconName = Cal.feastIcon[feasts[0].0] {
                    let attachment = NSTextAttachment()
                    let iconColor = (feasts[0].0 == .NoSign || feasts[0].0 == .SixVerse) ? UIColor.whiteColor() : UIColor.redColor()
                    let image = UIImage(named: iconName)?.maskWithColor(iconColor)
                    
                    attachment.image = imageResize(image!, sizeChange: CGSizeMake(15, 15))
                    myString.appendAttributedString(NSAttributedString(attachment: attachment))
                }
                
                myString.appendAttributedString(NSMutableAttributedString(string: feasts[0].1,
                    attributes: [NSForegroundColorAttributeName:UIColor.whiteColor()] ))
                
                saintsLabel.attributedText = myString
        }
        
    }
    
    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.NewData)
    }
    
}
