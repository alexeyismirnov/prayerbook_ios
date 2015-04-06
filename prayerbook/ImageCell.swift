//
//  ImageCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 30.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class ImageCell : ConfigurableCell {
    override class var cellId: String {
        get { return "ImageCell" }
    }
    
    @IBOutlet weak var title: RWLabel!
    @IBOutlet weak var icon: UIImageView!
    
}
