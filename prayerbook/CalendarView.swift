//
//  CalendarView.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 4/17/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

let dateChangedNotification = "DATE_CHANGED"

class CalendarViewCell: UICollectionViewCell {
    static let cellId = "CalendarCell"

    var collectionView: UICollectionView!
    var calendarDelegate: CalendarDelegate!
    var textSize : CGFloat? {
        didSet {
            calendarDelegate.textSize = textSize
        }
    }

    var textColor : UIColor? {
        didSet {
            calendarDelegate.themeColor = textColor
        }
    }

    var currentDate: Date! {
        didSet {
            calendarDelegate.currentDate = currentDate
            collectionView.reloadData()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        let initialFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0

        collectionView = UICollectionView(frame: initialFrame, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.clear

        collectionView.register(CalendarViewTextCell.self, forCellWithReuseIdentifier: CalendarViewTextCell.cellId)

        calendarDelegate = CalendarDelegate()
        calendarDelegate.containerType = .mainApp
        
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        let recognizer = UITapGestureRecognizer(target: self, action:#selector(doneWithDate(_:)))
        recognizer.numberOfTapsRequired = 1
        collectionView.addGestureRecognizer(recognizer)
        
        contentView.addSubview(collectionView)
    }
    
    func doneWithDate(_ recognizer: UITapGestureRecognizer) {
        let loc = recognizer.location(in: collectionView)
        var curDate: Date? = nil
        
        if let
            path = collectionView.indexPathForItem(at: loc),
            let cell = collectionView.cellForItem(at: path) as? CalendarViewTextCell,
            let dayNum = Int(cell.dateLabel.text!) {
            
            curDate = Date(dayNum, currentDate.month, currentDate.year)
            let userInfo:[String: Date] = ["date": curDate!]
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: dateChangedNotification), object: nil, userInfo: userInfo)

        }
        
    }

    
}
