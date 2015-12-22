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
    
    var calendarDelegate :CalendarGridDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarDelegate = CalendarGridDelegate()
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
    }
    

}
