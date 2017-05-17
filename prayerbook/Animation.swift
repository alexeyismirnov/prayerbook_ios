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

class DailyAnimatorInteractive : UIPercentDrivenInteractiveTransition {
    var shouldComplete = false
    var lastProgress: CGFloat=0
    var cancelled = false
    var velocity = CGPoint()
    
    func handlePan(recognizer: UIPanGestureRecognizer) {
        var translation = recognizer.translation(in: recognizer.view!.superview!)
        
        let screenWidth: CGFloat = UIScreen.main.bounds.size.width
        let percentThreshold: CGFloat = 0.5
        let automaticOverrideThreshold: CGFloat = 0.03
        
        if velocity.x > 0 && translation.x < 0 || velocity.x < 0 && translation.x > 0 {
            translation.x = 0
        }
    
        var progress: CGFloat = abs(translation.x / (screenWidth/2))
        progress = min(max(progress, 0.01), 0.99)

        switch recognizer.state {
        case .changed:
             if progress > lastProgress + automaticOverrideThreshold {
                shouldComplete = true
             
             } else {
                shouldComplete = progress > percentThreshold
             }
            update(progress)
            
        case .ended:
             if recognizer.state == .cancelled || shouldComplete == false {
                cancelled = true
                cancel()
             } else {
                cancelled = false
                finish()
             }
        default:
            break
        }
        
        lastProgress = progress
        
    }
    
}

class DailyAnimator: NSObject, UIViewControllerAnimatedTransitioning  {
    var direction: Animation.Direction!
    
    static let animationDuration = 0.7
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return DailyAnimator.animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)!
        let toVC = transitionContext.viewController(forKey: .to)!
        
        containerView.addSubview(fromVC.view)
        containerView.addSubview(toVC.view)
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        var vcFrame = finalFrame
        
        if direction == .positive {
            vcFrame.origin.x += finalFrame.width
        } else {
            vcFrame.origin.x -= finalFrame.width
        }
        
        toVC.view.frame = vcFrame
        
        UIView.animate(withDuration: DailyAnimator.animationDuration, delay: 0, options: [], animations: {
                        var vcFrame = finalFrame
                        toVC.view.frame = finalFrame
                        
                        if self.direction == .positive {
                            vcFrame.origin.x -= finalFrame.width
                        } else {
                            vcFrame.origin.x += finalFrame.width
                        }
                        fromVC.view.frame = vcFrame
        },
                       completion: { _ in
                        self.direction = .none
                        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}



