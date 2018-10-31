//
//  DateViewCell.swift
//  saints
//
//  Created by Alexey Smirnov on 11/4/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class DateViewCell: UICollectionViewCell, CellWithDate {
    @IBOutlet weak var dateLabel: UILabel!
    var currentDate : Date?
    static var selectedDate: Date?

    static var textSize : CGFloat?
    static var textColor : UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()

        var fontSize: Int!
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            fontSize = 16
        } else {
            fontSize = 18
        }

        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        dateLabel.textColor = Theme.textColor
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.baselineAdjustment = .alignCenters
    }
    
    func configureCell(date: Date?) {
        contentView.backgroundColor =  UIColor.clear
        currentDate = date
        
        guard let date = date else { dateLabel.text = ""; contentView.backgroundColor = .clear; return }
        
        dateLabel.text = String(format: "%d", date.day)

        if let textSize = DateViewCell.textSize {
            if let _ = Cal.getGreatFeast(date) {
                dateLabel.font = UIFont.boldSystemFont(ofSize: textSize)
            } else {
                dateLabel.font = UIFont.systemFont(ofSize: textSize)
            }
        }
        
        let (fastType, _) = Cal.getFastingDescription(date, FastingLevel())
        
        if let _ = Cal.getGreatFeast(date) {
            dateLabel.textColor = .red

        } else if DateViewCell.textColor != nil &&
            (fastType == .noFast || fastType == .noFastMonastic) {
            dateLabel.textColor =  DateViewCell.textColor
            
        } else {
            dateLabel.textColor = .black
        }
        
        if date == DateViewCell.selectedDate {
            contentView.backgroundColor = UIColor(hex:"#F0FFFF")
        } else {
            contentView.backgroundColor = UIColor(hex:Cal.fastingColor[fastType]!)
        }

    }

}
