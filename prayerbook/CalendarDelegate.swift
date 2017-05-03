//
//  CalendarGridViewController.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 12/15/15.
//  Copyright © 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

enum CalendarContainerType: Int {
    case mainApp=0, todayExtension
}

class CalendarDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {    
    var cal: Calendar = {
        let c = Calendar.current
        return c
    }()

    var currentDate: Date! {
        didSet {
            let monthStart = Date(1, currentDate.month, currentDate.year)
            cal.locale = Locale(identifier: "ru")
            startGap = (monthStart.weekday < cal.firstWeekday) ? 7 - (cal.firstWeekday-monthStart.weekday) : monthStart.weekday - cal.firstWeekday
        }
    }
    
    var startGap: Int!
    var selectedDate: Date?
    var containerType : CalendarContainerType!
    var textSize : CGFloat?
    var themeColor : UIColor?

    override init() {
        super.init()
    }

    @objc func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if (currentDate == nil) {
            return 0
        }
        
        let range = (Calendar.current as NSCalendar).range(of: NSCalendar.Unit.day, in: NSCalendar.Unit.month, for: currentDate)
        return range.length + startGap
    }

    @objc func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CalendarViewTextCell.cellId, for: indexPath) as! CalendarViewTextCell
        
        cell.contentView.backgroundColor =  UIColor.clear

        if (indexPath as NSIndexPath).row < startGap {
            cell.dateLabel.text = ""
            return cell
        }
        
        let dayIndex = (indexPath as NSIndexPath).row + 1 - startGap
        let curDate = Date(dayIndex, currentDate.month, currentDate.year)

        cell.dateLabel.text = String(format: "%d", dayIndex)
        cell.dateLabel.textColor = (Cal.isGreatFeast(curDate)) ? UIColor.red : UIColor.black
        
        if let textSize = textSize {
            cell.dateLabel.font = UIFont.systemFont(ofSize: textSize)
        }
        
        if curDate == selectedDate {
            cell.contentView.backgroundColor = UIColor(hex:"#FF8C00")

        } else {
            let (fastType, _) = Cal.getFastingDescription(curDate, FastingLevel())
            
            if fastType == .noFast || fastType == .noFastMonastic {
                var textColor:UIColor

                if Cal.isGreatFeast(curDate) {
                    textColor =  UIColor.red
                    
                } else if containerType == .mainApp {
                    if let color = themeColor {
                        textColor =  color
                        
                    } else {
                        textColor =  UIColor.black
                    }
                    
                } else if #available(iOS 10.0, *) {
                    textColor =  UIColor.black
                    
                } else {
                    textColor =  UIColor.white
                }
        
                cell.dateLabel.textColor =  textColor

            } else {
                cell.contentView.backgroundColor = UIColor(hex:Cal.fastingColor[fastType]!)
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.bounds.width-1) / 7.0
        return CGSize(width: cellWidth, height: cellWidth)
    }

    static func generateLabels(_ view: UIView, container: CalendarContainerType, standalone : Bool = false, textColor : UIColor? = nil, fontSize : CGFloat? = nil) {
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        formatter.locale = Locale(identifier: "ru")
        
        var cal = Calendar.current
        cal.locale = Locale(identifier: "ru")
        
        var dayLabel = [String]()
        
        if standalone {
            dayLabel = formatter.veryShortStandaloneWeekdaySymbols as [String]

        } else {
            dayLabel = formatter.veryShortWeekdaySymbols as [String]
        }
        
        for index in cal.firstWeekday...7 {
            if let label = view.viewWithTag(index-cal.firstWeekday+1) as? UILabel {
                label.text = dayLabel[index-1]
            }
        }
        
        if cal.firstWeekday > 1 {
            for index in 1...cal.firstWeekday-1 {
                if let label = view.viewWithTag(8-cal.firstWeekday+index) as? UILabel {
                    label.text = dayLabel[index-1]
                }
            }
        }
        
        if let color = textColor,
           let size = fontSize {
            for index in 1...7 {
                if let label = view.viewWithTag(index) as? UILabel {
                    label.textColor = color
                    label.font = UIFont.systemFont(ofSize: size)
                }
            }
        }
        
        if #available(iOS 10.0, *) {
            
        } else if container == .todayExtension  {
            for index in 1...7 {
                if let label = view.viewWithTag(index) as? UILabel {
                    label.textColor = UIColor.white
                }
            }
        }
        
    }

}
