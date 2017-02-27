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
        case none = 0
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

class DailyAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var direction: Animation.Direction!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        containerView.addSubview(toVC.view)
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var vcFrame = finalFrame
        
        if direction == .positive {
            vcFrame.origin.x += finalFrame.width
        } else {
            vcFrame.origin.x -= finalFrame.width
        }
        
        toVC.view.frame = vcFrame
        
        UIView.animate(withDuration: 1.0, delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0.2,
                       options: UIViewAnimationOptions(rawValue: 0),
                       animations: {
                        
                        var vcFrame = finalFrame
                        toVC.view.frame = finalFrame
                        
                        if self.direction == .positive {
                            vcFrame.origin.x -= finalFrame.width
                        } else {
                            vcFrame.origin.x += finalFrame.width
                        }
                        fromVC.view.frame = vcFrame
        },
                       completion: { _ in self.direction = .none;  transitionContext.completeTransition(true) })
    }
}



