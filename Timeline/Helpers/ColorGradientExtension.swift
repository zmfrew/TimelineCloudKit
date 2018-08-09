//
//  ColorGradientExtension.swift
//  Timeline
//
//  Created by Zachary Frew on 8/8/18.
//  Copyright © 2018 Zachary Frew. All rights reserved.
//

import UIKit

extension UIView {
    
    /*
     Adds a vertical gradient layer with two UIColors to the UIView.
     -  Parameter topColor: the top UIColor.
     -  Paraemeter bottomColor: the bottom UIColor.
     */
    
    func addVerticalGradientLayer(topColor: UIColor, bottomColor: UIColor) {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [topColor.cgColor, bottomColor.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
}

extension UIColor {
    
    // FIXME: Create new primary color.
    static var primaryColor: UIColor {
        return UIColor(red: 254/255, green: 218/255, blue: 119/255, alpha: 1)
//        return UIColor(red: 210/255, green: 109/255, blue: 180/255, alpha: 1)
    }
    
    // FIXME: Create new secondary color.
    static var secondaryColor: UIColor {
        return UIColor(red: 129/255, green: 52/255, blue: 175/255, alpha: 1)
//        return UIColor(red: 52/255, green: 148/255, blue: 230/255, alpha: 1)
    }
    
}
