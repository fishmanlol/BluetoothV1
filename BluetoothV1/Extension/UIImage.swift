//
//  UIImage.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/15/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIImage {
    static func from(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    static var oximeter: UIImage? {
        return UIImage(named: "pulse_oximeter")
    }
}
