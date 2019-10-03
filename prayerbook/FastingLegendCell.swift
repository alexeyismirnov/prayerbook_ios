//
//  FastingLegendCell.swift
//  ponomar
//
//  Created by Alexey Smirnov on 10/1/19.
//  Copyright © 2019 Alexey Smirnov. All rights reserved.
//

import UIKit
import swift_toolkit

class FastingLegendCell: UICollectionViewCell {
    var icon: UIImageView!
    var title: UILabel!
    var con : [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        title = UILabel()
        title.numberOfLines = 0
        title.adjustsFontSizeToFitWidth = false
        
        icon = UIImageView()

        title.translatesAutoresizingMaskIntoConstraints = false
        icon.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.addSubview(icon)
        
        con = [
            title.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            title.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            icon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 15.0),
            icon.heightAnchor.constraint(equalToConstant: 15.0),
            
            icon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            title.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            icon.trailingAnchor.constraint(equalTo: title.leadingAnchor, constant: -10.0),
        ]
        
        NSLayoutConstraint.activate(con)

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FastingLegendCell: ReusableView {}
