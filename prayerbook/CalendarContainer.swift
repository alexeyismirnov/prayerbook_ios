//
//  CalendarContainer.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/20/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarContainer: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let cal = storyboard!.instantiateViewControllerWithIdentifier("CalendarGrid") as! CalendarGridViewController

        navigationController?.pushViewController(cal, animated: false)
    }
    


}
