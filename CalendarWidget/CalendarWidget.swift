//
//  CalendarWidget.swift
//  CalendarWidget
//
//  Created by Alexey Smirnov on 11/10/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//


import UIKit
import NotificationCenter
import swift_toolkit

class CalendarWidget : CalendarWidgetViewController {
    override func viewDidLoad() {
        AppGroup.id = "group.rlc.ponomar2"
        
        Translate.files = ["trans_ui_en", "trans_cal_en",
                           "trans_ui_cn", "trans_cal_cn", "trans_library_cn",
                           "trans_ui_hk", "trans_cal_hk", "trans_library_hk"]
        
        super.viewDidLoad()
    }
}


