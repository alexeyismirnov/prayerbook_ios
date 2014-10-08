//
//  CalendarViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 10/8/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, RDVCalendarViewDelegate {

    @IBOutlet weak var _calendarView: RDVCalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        _calendarView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        _calendarView.separatorStyle = .Horizontal
        _calendarView.delegate = self
        _calendarView.backgroundColor = UIColor.whiteColor()
    }

}
