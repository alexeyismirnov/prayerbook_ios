//
//  YearlyMonthViewCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 5/1/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class YearlyMonthViewCell: UICollectionViewCell {
    static let cellId = "YearlyMonthViewCell"

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var calendarDelegate: CalendarDelegate!

    var currentDate : Date! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL"
            formatter.locale = Locale(identifier: "ru")

            monthLabel.text = formatter.string(from: currentDate).capitalizingFirstLetter()
            monthLabel.font = UIFont.systemFont(ofSize: YC.config.titleFontSize)
            monthLabel.textColor = CalendarDelegate.isSharing ? .black : Theme.textColor

            calendarDelegate.currentDate = currentDate
            collectionView.reloadData()
            
            CalendarDelegate.generateLabels(self, container: .mainApp, standalone: true, textColor: Theme.textColor, fontSize: YC.config.fontSize)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.backgroundColor = .clear

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        collectionView.register(CalendarViewTextCell.self, forCellWithReuseIdentifier: CalendarViewTextCell.cellId)
        
        calendarDelegate = CalendarDelegate()
        calendarDelegate.containerType = .mainApp
        
        calendarDelegate.textSize = YC.config.fontSize
        calendarDelegate.themeColor = CalendarDelegate.isSharing ? .black : Theme.textColor
        
        collectionView.delegate = calendarDelegate
        collectionView.dataSource = calendarDelegate
        
        collectionView.layer.addBorder(edge: .top, color: CalendarDelegate.isSharing ? .black : Theme.secondaryColor, thickness: 1)

    }

}
