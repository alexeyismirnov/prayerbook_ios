//
//  ZernaModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 4/5/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

class ZernaModel : EbookModel, PreachmentModel {
    public init() {
        super.init("zerna")
    }
    
    static let shared = ZernaModel()
    
    func getPreachment(_ date: Date) -> [Preachment] {
        let cal = Cal.fromDate(date)
        let startDate = Date(1, 1, cal.year)
        
        let numChapters = getNumChapters(IndexPath(row: 0, section: 0))
        let index = (startDate >> date) % numChapters
        
        let pos = BookPosition(model: ZernaModel.shared, index: IndexPath(row: index, section: 0))
        return [Preachment(position: pos, title: title, subtitle: getTitle(at: pos)!)]
    }
}


