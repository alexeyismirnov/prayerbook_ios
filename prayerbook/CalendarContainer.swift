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
    
    override func viewDidAppear(animated: Bool) {
        let upperBorder = CALayer();
        upperBorder.backgroundColor = UIColor.lightGrayColor().CGColor;
        upperBorder.frame = CGRectMake(0, 0, CGRectGetWidth(collectionView.frame), 2.0);
        collectionView.layer.addSublayer(upperBorder)
    }
    

}
