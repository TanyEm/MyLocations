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
    }
}
