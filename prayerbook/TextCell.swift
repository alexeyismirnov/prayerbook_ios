//
//  TextCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 27.03.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class TextCell : ConfigurableCell {
    
    override class var cellId: String {
        get { return "TextCell" }
    }

    @IBOutlet weak var title: RWLabel!
    
}
