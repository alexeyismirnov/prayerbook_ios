//
//  CalendarViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/8/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, RDVCalendarViewDelegate {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var calendarView: RDVCalendarView!
    weak var delegate: DailyPrayers!

    override func viewDidLoad() {
        super.viewDidLoad()

        var button_left = UIBarButtonItem(image: UIImage(named: "arrow-left"), style: .Plain, target: self, action: "prev_month")
        var button_right = UIBarButtonItem(image: UIImage(named: "arrow-right"), style: .Plain, target: self, action: "next_month")
        button_left.imageInsets = UIEdgeInsetsMake(0,0,0,-20)
        
        navigationItem.rightBarButtonItems = [button_right, button_left]

        calendarView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        calendarView.separatorStyle = .Horizontal
        calendarView.delegate = self
        calendarView.backgroundColor = UIColor.whiteColor()
        calendarView.currentDayColor = UIColor.whiteColor()

        title =  calendarView.monthLabel.text
    }
    
    override func viewWillAppear(animated: Bool) {
        calendarView.selectedDate = delegate.currentDate
        updateDescription()
    }
    
    func prev_month() {
        calendarView.showPreviousMonth()
        calendarView.selectedDate = nil
    }
    
    func next_month() {
        calendarView.showNextMonth()
        calendarView.selectedDate = nil
    }
    
    @IBAction func done(sender: AnyObject) {
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func doneWithDate(recognizer: UITapGestureRecognizer) {
        let cell = recognizer.view as RDVCalendarDayCell
        let index = calendarView.indexForDayCell(cell)
        var currentDate = NSDateComponents(day: index+1, month: calendarView.month.month, year: calendarView.month.year).toDate()

        delegate.currentDate = currentDate
        delegate.reload()
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func updateDescription() {
        descriptionLabel.attributedText = NSAttributedString(string: " ")

        if (calendarView.selectedDate == nil) {
            return
        }
        
        if let txt = FeastCalendar.getAttributedDayDescription(calendarView.selectedDate) {
            descriptionLabel.attributedText = txt
        }
    }
    
    // MARK: RDVCalendarViewDelegate
    
    func calendarView(calendarView: RDVCalendarView!, didChangeMonth month: NSDateComponents!) {
        title = calendarView.monthLabel.text
        updateDescription()
    }
    
    func calendarView(calendarView: RDVCalendarView!, configureDayCell dayCell: RDVCalendarDayCell!, atIndex index: Int) {
        
        var recognizer = UITapGestureRecognizer(target: self, action:Selector("doneWithDate:"))
        recognizer.numberOfTapsRequired = 2
        dayCell.addGestureRecognizer(recognizer)

        var curDate = NSDateComponents(day: index+1, month: calendarView.month.month, year: calendarView.month.year).toDate()
        
        if let _ = FeastCalendar.getDayDescription(curDate) {
            dayCell.textLabel.textColor = UIColor.redColor()

        } else {
            dayCell.textLabel.textColor = UIColor.blackColor()
        }
    }
    
    func calendarView(calendarView: RDVCalendarView!, didSelectDate date: NSDate!) {
        updateDescription()
    }
    
}
