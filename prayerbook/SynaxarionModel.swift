//
//  SynaxarionModel.swift
//  ponomar
//
//  Created by Alexey Smirnov on 2/7/22.
//  Copyright © 2022 Alexey Smirnov. All rights reserved.
//

import Foundation
import swift_toolkit

class SynaxarionModel : EbookModel, PreachmentModel {
    public init() {
        super.init("synaxarion")
    }
    
    static let shared = SynaxarionModel()
    
    func getPreachment(_ date: Date) -> [Preachment] {
        var dates = [Date]()
        let cal = Cal.fromDate(date)
       
        dates = [
            cal.greatLentStart-22.days,cal.greatLentStart-15.days,cal.greatLentStart-9.days,cal.greatLentStart-8.days,
            cal.greatLentStart-2.days,cal.greatLentStart-1.days,cal.greatLentStart+5.days,cal.greatLentStart+6.days,
            cal.greatLentStart+13.days,cal.greatLentStart+20.days,cal.greatLentStart+27.days,cal.greatLentStart+31.days,
            cal.greatLentStart+33.days, cal.greatLentStart+34.days,

            cal.pascha-8.days,cal.pascha-7.days,cal.pascha-6.days,
            cal.pascha-5.days,cal.pascha-4.days,cal.pascha-3.days,cal.pascha-2.days,
            cal.pascha-1.days,
            cal.pascha, cal.pascha+5.days,cal.pascha+7.days,cal.pascha+14.days,
            cal.pascha+21.days, cal.pascha+24.days,cal.pascha+28.days,cal.pascha+35.days, cal.pascha+39.days,
            cal.pascha+42.days,cal.pascha+49.days, cal.pascha+50.days, cal.pascha+56.days,
        ]
        
        if let index = dates.firstIndex(of: date) {
            let pos = BookPosition(model: SynaxarionModel.shared, index: IndexPath(row: index, section: 0))
            return [Preachment(position: pos, title: getTitle(at: pos)!)]
            
        } else {
            return []
        }
    }
}

