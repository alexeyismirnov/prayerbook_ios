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
    
    @IBOutlet weak var collectionView: UICollectionView!
    var currentDate: NSDate = {
        return NSDateComponents(date: NSDate()).toDate()
    }()
    
    var calendarDelegate: CalendarGridDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let prefs = NSUserDefaults(suiteName: "group.rlc.ponomar")!

        if let language = prefs.objectForKey("language") as? String {
            Translate.language = language
        }
        
        calendarDelegate = CalendarGridDelegate()
        calendarDelegate.containerType = .TodayExtension

        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate

        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()

    }

    func widgetMarginInsetsForProposedMarginInsets(defaultMarginInsets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsetsZero
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {

        completionHandler(NCUpdateResult.NewData)
    }
    
}
