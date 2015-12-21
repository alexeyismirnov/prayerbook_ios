//
//  CalendarGridViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/15/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CalendarTextCell"

class CalendarGridViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var currentDate: NSDate!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentDate = ChurchCalendar.currentDate
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let range = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: currentDate)
        return range.length
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarViewTextCell
        
        cell.dateLabel.text = String(format: "%d", indexPath.row)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(40, 40)
    }
    


}
