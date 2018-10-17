//
//  YearlyMonthViewCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 5/1/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class YearlyMonthViewCell: UICollectionViewCell {
    static let cellId = "YearlyMonthViewCell"

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var calendarDelegate: CalendarDelegate!
    var appeared = false

    var currentDate : Date! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL"
            formatter.locale = Locale(identifier: "ru")

            monthLabel.text = formatter.string(from: currentDate).capitalizingFirstLetter()
            monthLabel.font = UIFont.systemFont(ofSize: YC.config.titleFontSize)
            monthLabel.textColor = YearlyCalendar.isSharing ? .black : Theme.textColor

            if appeared {
                indicator.stopAnimating()
                
                collectionView.delegate = calendarDelegate
                collectionView.dataSource = calendarDelegate
            
            }
            
            calendarDelegate.currentDate = currentDate
            collectionView.reloadData()
            
            CalendarContainer.generateLabels(self, standalone: true, textColor: YearlyCalendar.isSharing ? .black : Theme.textColor, fontSize: YC.config.fontSize)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.backgroundColor = .clear
        indicator.hidesWhenStopped = true
        indicator.color = Theme.textColor
        indicator.startAnimating()

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
                
        calendarDelegate = CalendarDelegate()

        let cellId = "DateViewCell"
        collectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        calendarDelegate.cellReuseIdentifier = cellId
        
        DateViewCell.textColor = YearlyCalendar.isSharing ? .black : Theme.textColor
        DateViewCell.textSize = YC.config.fontSize
        
        collectionView.layer.addBorder(edge: .top, color: YearlyCalendar.isSharing ? .black : Theme.secondaryColor, thickness: 1)

    }
    

}
