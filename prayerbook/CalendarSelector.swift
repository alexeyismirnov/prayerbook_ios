//
//  CalendarSelector.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/24/18.
//  Copyright © 2018 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class CalendarSelector: UITableViewController, PopupContentViewController {
    weak var delegate : DailyTab2!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: "#FFEBCD")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            delegate.showMonthlyCalendar()
        } else {
            delegate.showYearlyCalendar()
        }
    }
    
    func sizeForPopup(_ popupController: PopupController, size: CGSize, showingKeyboard: Bool) -> CGSize {
        return CGSize(width: 200, height: 180)
    }
    
}

