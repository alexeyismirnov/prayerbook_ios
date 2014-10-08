//
//  CalendarViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/8/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, RDVCalendarViewDelegate {

    @IBOutlet weak var calendarView: RDVCalendarView!
    weak var delegate: UIViewController!

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

        title =  calendarView.monthLabel.text
    }
    
    func prev_month() {
        calendarView.showPreviousMonth()
    }
    
    func next_month() {
        calendarView.showNextMonth()
    }
    
    @IBAction func done(sender: AnyObject) {
        delegate.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func calendarView(calendarView: RDVCalendarView!, didChangeMonth month: NSDateComponents!) {
        title =  calendarView.monthLabel.text
    }
    

}
