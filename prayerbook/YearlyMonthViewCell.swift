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
    let theme = YearCalendarGridTheme.shared

    var currentDate : Date! {
        didSet {
            let formatter = DateFormatter()
            formatter.dateFormat = "LLLL"
            formatter.locale = Translate.locale

            monthLabel.text = formatter.string(from: currentDate).capitalizingFirstLetter()
            monthLabel.font = UIFont.systemFont(ofSize: theme.titleFontSize)
            monthLabel.textColor = theme.textColor

            if appeared {
                indicator.stopAnimating()
                
                collectionView.delegate = calendarDelegate
                collectionView.dataSource = calendarDelegate
            }
            
            calendarDelegate.currentDate = currentDate
            collectionView.reloadData()
            
            CalendarContainer.generateLabels(self, standalone: true, textColor: theme.textColor, fontSize: theme.fontSize)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        collectionView.backgroundColor = .clear
        indicator.hidesWhenStopped = true
        indicator.color = Theme.textColor
        indicator.startAnimating()

        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
                
        calendarDelegate = CalendarDelegate(fontSize: theme.fontSize, textColor: theme.textColor)
        
        collectionView.layer.addBorder(edge: .top, color: theme.textColor, thickness: 1)

    }
    

}
