//
//  CalendarImageCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 5/3/17.
//  Copyright © 2017 Alexey Smirnov. All rights reserved.
//

import UIKit

class CalendarImageCell: UICollectionViewCell {
    static let cellId = "CalendarImageCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
