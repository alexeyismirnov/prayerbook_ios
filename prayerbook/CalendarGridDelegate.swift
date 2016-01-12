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

    let cal: NSCalendar = {
        let c = NSCalendar.currentCalendar()
        c.locale = NSLocale(localeIdentifier: (Translate.language == "en") ? "en" : "ru")
        return c
    }()

    var currentDate: NSDate! {
        didSet {
            let monthStart = NSDate(1, currentDate.month, currentDate.year)
            startGap = (monthStart.weekday < cal.firstWeekday) ? 7 - (cal.firstWeekday-monthStart.weekday) : monthStart.weekday - cal.firstWeekday
        }
    }
    
    var startGap: Int!

    override init() {
        super.init()
    }

    @objc func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    @objc func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let range = NSCalendar.currentCalendar().rangeOfUnit(NSCalendarUnit.Day, inUnit: NSCalendarUnit.Month, forDate: currentDate)
        return range.length + startGap
    }

    @objc func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! CalendarViewTextCell
        
        if indexPath.row < startGap {
            cell.dateLabel.text = ""
            cell.contentView.backgroundColor = UIColor.whiteColor()
            return cell
        }
        
        let dayIndex = indexPath.row + 1 - startGap
        let curDate = NSDate(dayIndex, currentDate.month, currentDate.year)

        cell.dateLabel.text = String(format: "%d", dayIndex)
        cell.dateLabel.textColor = (Cal.isGreatFeast(curDate)) ? UIColor.redColor() : UIColor.blackColor()

        switch Cal.getFastingDescription(curDate).0 {
        case .Vegetarian:
            cell.contentView.backgroundColor = UIColor(hex:"#30D5C8")
            break
        case .FishAllowed:
            cell.contentView.backgroundColor = UIColor(hex:"#FADFAD")
            break
        case .Cheesefare, .FastFree:
            cell.contentView.backgroundColor = UIColor(hex:"#00BFFF")
            break
        default:
            cell.contentView.backgroundColor = UIColor.whiteColor()
            break
        }
        
        return cell
    }
    
    @objc func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 7.0
        return CGSizeMake(cellWidth, cellWidth)
    }
    

}
