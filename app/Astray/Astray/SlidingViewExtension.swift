//
//  SlidingViewExtension.swift
//  Astray
//
//  Created by Katherine Bernstein on 3/17/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit

extension UIView {
    func slideUpFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideUpFromBottomTransition = CATransition()
        if let delegate: AnyObject = completionDelegate {
            slideUpFromBottomTransition.delegate = delegate
        }
        slideUpFromBottomTransition.type = kCATransitionPush
        slideUpFromBottomTransition.subtype = kCATransitionFromTop
        slideUpFromBottomTransition.duration = duration
        slideUpFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideUpFromBottomTransition.fillMode = kCAFillModeForwards
        
        self.layer.addAnimation(slideUpFromBottomTransition, forKey: "slideUpFromBottomTransition")
    }
    
    func slideDownFromTop(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
        let slideDownFromTopTransition = CATransition()
        if let delegate: AnyObject = completionDelegate {
            slideDownFromTopTransition.delegate = delegate
        }
        slideDownFromTopTransition.type = kCATransitionPush
        slideDownFromTopTransition.subtype = kCATransitionFromBottom
        slideDownFromTopTransition.duration = duration
        slideDownFromTopTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        slideDownFromTopTransition.fillMode = kCAFillModeRemoved
        
        self.layer.addAnimation(slideDownFromTopTransition, forKey: "slideUpFromBottomTransition")
    }
}
