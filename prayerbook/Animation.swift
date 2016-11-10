//
//  Animation.swift
//  prayerbook
//
//  Created by Alexey Smirnov on 11/10/16.
//  Copyright © 2016 Alexey Smirnov. All rights reserved.
//

import UIKit

class Animation {
    enum Direction: Int {
        case positive = 1
        case negative = -1
    }
    
    enum Orientation {
        case horizontal
        case vertical
    }

    static func swipe(orientation: Orientation, direction : Direction, inView view: UIView, update: @escaping () -> ()) {
        view.constraints.forEach { con in
            if con.identifier == "calendar" {
                if orientation == .horizontal {
                    con.constant = view.frame.width * CGFloat(direction.rawValue) * -1.0
                } else {
                    con.constant = view.frame.height * CGFloat(direction.rawValue) * -1.0
                }
            }
        }
        
        UIView.animate(withDuration: 0.5,
                       animations: { view.layoutIfNeeded() },
                       completion: { _ in
                        view.constraints.forEach { con in
                            if con.identifier == "calendar" {
                                if orientation == .horizontal {
                                    con.constant = view.frame.width * CGFloat(direction.rawValue)
                                } else {
                                    con.constant = view.frame.height * CGFloat(direction.rawValue)
                                }
                                
                                update()
                            }
                        }
                        
                        view.layoutIfNeeded()
                        
                        view.constraints.forEach { con in
                            if con.identifier == "calendar" {
                                con.constant = 0
                            }
                        }
                        
                        UIView.animate(withDuration: 0.5,
                                       animations: { view.layoutIfNeeded() },
                                       completion: nil
                        )
                        
        })
    }
    
}

