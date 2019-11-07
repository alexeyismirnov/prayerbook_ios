//
//  WeekCalendarCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 11/7/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

public class WeekCalendarCell : UITableViewCell {
    var dateLabel: UILabel!
    var title: RWLabel!
    var subtitle: RWLabel!
    var border: UIView!

    let dateLabelHeight = CGFloat(60.0)
    var con : [NSLayoutConstraint]!
    
    let formatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.timeStyle = .none
        switch Translate.language {
        case "ru":
            formatter.dateFormat = "d/M"
            break
        case "cn":
            formatter.dateFormat = "M月d日"
            break
        default:
            formatter.dateFormat = "MMM d"
        }
        formatter.locale = Translate.locale
        
        return formatter
    }()

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createLabel(fontSize: CGFloat) -> RWLabel {
        let label = RWLabel()
        label.textColor = Theme.textColor
        label.numberOfLines = 3
        label.preferredMaxLayoutWidth = 1000
        
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }
    
    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        border = UIView()
        border.backgroundColor = .gray
        border.translatesAutoresizingMaskIntoConstraints = false

        dateLabel = UILabel()
        dateLabel.textAlignment = .center
        dateLabel.numberOfLines = 1
        dateLabel.adjustsFontSizeToFitWidth = true
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
                
        title = createLabel(fontSize: 18)
        subtitle = createLabel(fontSize: 18)
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(title)
        contentView.addSubview(subtitle)
        contentView.addSubview(border)
        
        con = [
            dateLabel.widthAnchor.constraint(equalToConstant: dateLabelHeight),
            dateLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            dateLabel.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -5.0),

            title.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 10.0),
            title.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0.0),
            
            subtitle.leftAnchor.constraint(equalTo: dateLabel.rightAnchor, constant: 10.0),
            subtitle.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5.0),
            subtitle.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -5.0),
            
            border.heightAnchor.constraint(equalToConstant: 1.0),
            border.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0.0),
            border.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0.0),
            border.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5.0),

        ]
        
        NSLayoutConstraint.activate(con)//.map() { $0.priority = UILayoutPriority(999); return $0 })
    }
    
    func removeDates(_ string1: String) -> String {
        let regex = try! NSRegularExpression(pattern: " \\(.*?\\)", options: .caseInsensitive)
        return regex.stringByReplacingMatches(in: string1, options: [], range: NSRange(location: 0, length: string1.count), withTemplate: "")
    }
    
    func configureCell(date: Date, content: [(FeastType, String)], cellWidth: CGFloat) {
        let fasting = FastingModel.fasting(forDate: date)
        
        let textColor = Theme.textColor
        let fontSize = CGFloat(18)

        subtitle.text = ""
        dateLabel.text = formatter.string(from: date)
        
        if let _ = Cal.getGreatFeast(date) {
            dateLabel.font = UIFont.boldSystemFont(ofSize: fontSize)
            dateLabel.textColor = .red
            title.textColor = .red
            
        } else {
            dateLabel.font = UIFont.systemFont(ofSize: fontSize)
            
            if fasting.type == .noFast || fasting.type == .noFastMonastic {
                dateLabel.textColor = textColor
                
            } else {
                dateLabel.textColor = .black
            }
        }
        
        dateLabel.backgroundColor = fasting.color
                
        title.text = removeDates(content[0].1)
        
        bounds = CGRect(x: 0, y: 0, width: cellWidth, height: bounds.height)
        setNeedsLayout()
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        if size.height < dateLabelHeight && content.count > 1  {
            subtitle.numberOfLines = 2
            subtitle.text = removeDates(content[1].1)
        }
    }
    
}

extension WeekCalendarCell: ReusableView {}
