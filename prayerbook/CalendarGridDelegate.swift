//
//  CalendarGridViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/15/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

private let reuseIdentifier = "CalendarTextCell"

class CalendarGridDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var currentDate: NSDate!

    override init() {
        super.init()
        currentDate = ChurchCalendar.currentDate
    }

    @objc func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let range = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: currentDate)
        return range.length
    }

    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarViewTextCell
        
        cell.dateLabel.text = String(format: "%d", indexPath.row)
        
        return cell
    }
    
    @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 7.0
        return CGSizeMake(cellWidth, cellWidth)
    }
    

}
