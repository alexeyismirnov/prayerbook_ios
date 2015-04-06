//
//  TextDetailsCell.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 06.04.15.
//  Copyright (c) 2015 Alexey Smirnov. All rights reserved.
//

import UIKit

class TextDetailsCell : ConfigurableCell {
    override class var cellId: String {
        get { return "TextDetailsCell" }
    }
    
    @IBOutlet weak var title: RWLabel!
    @IBOutlet weak var subtitle: RWLabel!
}
