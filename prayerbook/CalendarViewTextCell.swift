//
//  CalendarViewTextCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/15/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarViewTextCell: UICollectionViewCell {
    static let cellId = "CalendarTextCell"

    var dateLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        var fontSize: Int!
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            fontSize = 16
        } else {
            fontSize = 18
        }
        
        let initialFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)

        dateLabel = UILabel(frame: initialFrame)
        
        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.baselineAdjustment = .alignCenters

        contentView.addSubview(dateLabel)
    }
    
}
