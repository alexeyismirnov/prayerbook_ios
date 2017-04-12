//
//  CalendarContainer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/20/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit
import Chameleon

class CalendarContainer: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let cal: Calendar = {
        var c = Calendar.current
        c.locale = Locale(identifier: "ru")
        return c
    }()

    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru")
        return formatter
    }()
    
    var currentDate: Date = ChurchCalendar.currentDate as Date
    var calendarDelegate: CalendarGridDelegate!
    var delegate: DailyTab!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor =  .flatSand
        
        calendarDelegate = CalendarGridDelegate()
        calendarDelegate.containerType = .mainApp
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        collectionView.backgroundColor = UIColor.clear
        
        collectionView.constraints.forEach { con in
            if con.identifier == "calendar-width" {
                if (UIDevice.current.userInterfaceIdiom == .phone) {
                    con.constant = 300
                } else {
                    con.constant = 500
                }
            }
        }
        
        view.setNeedsLayout()
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(CalendarContainer.doneWithDate(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        calendarDelegate.generateLabels(view)
        
        refresh()
    }
    
    func doneWithDate(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        var curDate: Date? = nil
        
        if let
            path = collectionView.indexPathForItem(at: loc),
            let cell = collectionView.cellForItem(at: path) as? CalendarViewTextCell,
            let dayNum = Int(cell.dateLabel.text!) {
                curDate = Date(dayNum, currentDate.month, currentDate.year)
        }
        
        delegate.updateDate(curDate)
    }
    
    func refresh() {
        title = formatter.string(from: currentDate).capitalizingFirstLetter()
        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()
    }

    @IBAction func prevMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .negative,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate - 1.months
                            self.refresh()
        })
    }
    
    @IBAction func nextMonth(_ sender: AnyObject) {
        Animation.swipe(orientation: .horizontal,
                        direction: .positive,
                        inView: view,
                        update: {
                            self.currentDate = self.currentDate + 1.months
                            self.refresh()
        })
    }

}
