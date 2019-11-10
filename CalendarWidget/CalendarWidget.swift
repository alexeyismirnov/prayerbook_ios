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

class CalendarWidget : MainViewController {
    override func viewDidLoad() {
        AppGroup.id = "group.rlc.ponomar-ru"
        Translate.files = ["trans_ui_ru", "trans_cal_ru", "trans_library_ru"]

        super.viewDidLoad()
    }
}

