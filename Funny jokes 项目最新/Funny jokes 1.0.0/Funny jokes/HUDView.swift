//
//  HUDView.swift
//  MyLocations
//
//  Created by Lxrent52 on 15/7/30.
//  Copyright © 2015年 zhihong. All rights reserved.
//

import UIKit

class HUDView: UIView {

    var text = ""
    class func hudViewInView(view: UIView, animated: Bool) -> HUDView {
        let hudView = HUDView(frame: view.bounds)
        
        hudView.backgroundColor = UIColor.clearColor()
        
        view.addSubview(hudView)
        
        hudView.viewAnimation(animated)
        
        return hudView
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
//        let boxSize = CGSize(width: boxWidth, height: boxHeight)
        let boxRect = CGRect(x: self.center.x - boxWidth / 2, y: self.center.y - boxHeight / 2, width: boxWidth, height: boxHeight)
        
        let roundBox = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
//        UIColor(red: 0.2, green: 0.3, blue: 0.3, alpha: 1).setFill()
        UIColor.grayColor().setFill()
        roundBox.fill()
        
        // 加图片
        if let image = UIImage(named: "Checkmark") {
            
            let imagePoint = CGPoint(x: center.x - (image.size.width / 2), y: center.y - (image.size.height / 2) - boxRect.size.height / 5)
            
            image.drawAtPoint(imagePoint)
        }
        
        // 加文字
        
        let attributs = [NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor(white: 1, alpha: 0.7)]
        let textSize = text.sizeWithAttributes(attributs)
        
        let textPoint = CGPoint(x: center.x - (textSize.width / 2), y: center.y + (textSize.height) - boxRect.height / 7)
        text.drawAtPoint(textPoint, withAttributes: attributs)
        
    }
    
    func viewAnimation(animated: Bool) {
        
        self.transform = CGAffineTransformMakeScale(1.3, 1.3)
        
        self.alpha = 0
        
        if animated {

        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: UIViewAnimationOptions(rawValue: 0), animations: { () -> Void in
            self.alpha = 1
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
        }
    }

}
