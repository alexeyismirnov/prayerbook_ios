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
    var fontSize: CGFloat!

    static var selectedDate: Date?
    static var textSize : CGFloat?
    static var textColor : UIColor?
    
    @IBOutlet weak var labelHeight: NSLayoutConstraint!
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let textSize = DateViewCell.textSize {
            fontSize = textSize
        } else {
            fontSize = (UIDevice.current.userInterfaceIdiom == .phone ? 16.0 : 18.0)
        }
       
        dateLabel.numberOfLines = 1
        dateLabel.font = UIFont.systemFont(ofSize: fontSize)
        dateLabel.textColor = Theme.textColor
        dateLabel.adjustsFontSizeToFitWidth = false
        dateLabel.clipsToBounds = true
        dateLabel.textAlignment = .center
        dateLabel.baselineAdjustment = .alignCenters
    }
    
    func configureCell(date: Date?) {
        contentView.backgroundColor =  UIColor.clear
        dateLabel.backgroundColor =  UIColor.clear

        currentDate = date
        
        guard let date = date else { dateLabel.text = ""; contentView.backgroundColor = .clear; return }
        
        dateLabel.text = String(format: "%d", date.day)

        if let _ = Cal.getGreatFeast(date) {
            dateLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            dateLabel.font = UIFont.systemFont(ofSize: fontSize)
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
        
        contentView.backgroundColor = UIColor(hex:Cal.fastingColor[fastType]!)
        
        labelHeight.constant = contentView.frame.height
        labelWidth.constant = contentView.frame.width
        
        if date == DateViewCell.selectedDate {
            labelHeight.constant = fontSize + 15.0
            labelWidth.constant = fontSize + 15.0
            
            dateLabel.layer.cornerRadius = fontSize
            dateLabel.backgroundColor = .red
            dateLabel.textColor = .white
        }

    }

}
