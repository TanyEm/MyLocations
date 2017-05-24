//
//  HudView.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 19.05.17.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import UIKit

class HudView: UIView {
    
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.show(animated: animated)
        return hudView
    }
    
    //The method is invoked whenever UIKit wants your view to redraw itself.
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        //It is the CGRect structure that represents a rectangular. You use it to calculate the position for the HUD.
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        //This loads the checkmark image into a UIImage object. Then it calculates the position for that image based on the center coordinate of the HUD view (center) and the dimensions of the image (image.size).
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(
                x: center.x - round(image.size.width / 2),
                y: center.y - round(image.size.height / 2) - boxHeight / 8)
            image.draw(at: imagePoint)
        }
        
        let attribs = [ NSFontAttributeName: UIFont.systemFont(ofSize: 16),
                        NSForegroundColorAttributeName: UIColor.white ]
        let textSize = text.size(attributes: attribs)
        let textPoint = CGPoint(
            x: center.x - round(textSize.width / 2),
            y: center.y - round(textSize.height / 2) + boxHeight / 4)
        text.draw(at: textPoint, withAttributes: attribs)
    }
    
    func show(animated: Bool) {
        if animated {
            //It is setted up the initial state of the view before the animation starts.
            // Here is setted alpha to 0, making the view fully transparent.
            alpha = 0
            //It is setted the transform to a scale factor of 1.3
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            /*
             
             UIView.animate(withDuration: 0.3, animations: {
             self.alpha = 1
             self.transform = CGAffineTransform.identity
             })
             */
            //There is called UIView.animate(withDuration:...) to set up ananimation
            // UIKit will animate the properties that are changed inside the closure from their initial state to the final state.
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                // Inside the closure, set up the new state of the view that its hould have after the animation completes.
                // You set alpha to 1, which means the HudView is now fully opaque.
                self.alpha = 1
                // You also set the transform to the “identity” transform, restoring the scale back to normal.
                self.transform = CGAffineTransform.identity
            },
                           completion: nil)
        }
    }
}
