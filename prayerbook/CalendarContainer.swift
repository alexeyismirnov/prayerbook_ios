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
    
    let cal: Calendar = {
        var c = Calendar.current
        c.locale = Locale(identifier: (Translate.language == "en") ? "en" : "zh_CN")
        return c
    }()

    var formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: (Translate.language == "en") ? "en" : "zh_CN")
        return formatter
    }()
    
    var currentDate: Date = ChurchCalendar.currentDate as Date
    var calendarDelegate: CalendarGridDelegate!
    var delegate: DailyTab!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarDelegate = CalendarGridDelegate()
        calendarDelegate.containerType = .mainApp
        
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(CalendarContainer.doneWithDate(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        calendarDelegate.generateLabels(view)
        
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let upperBorder = CALayer();
        upperBorder.backgroundColor = UIColor.lightGray.cgColor;
        upperBorder.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 2.0);
        collectionView.layer.addSublayer(upperBorder)
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
        title = formatter.string(from: currentDate)
        calendarDelegate.currentDate = currentDate
        collectionView.reloadData()
    }

    @IBAction func prevMonth(_ sender: AnyObject) {
        currentDate = currentDate - 1.months
        refresh()
    }
    
    @IBAction func nextMonth(_ sender: AnyObject) {
        currentDate = currentDate + 1.months
        refresh()
    }
    

}
