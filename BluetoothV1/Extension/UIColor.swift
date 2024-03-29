//
//  UIColor.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let lightGray = UIColor(r: 207, g: 212, b: 217)
    static let drakGray = UIColor(r: 170, g: 175, b: 180)
    static let lightBlue = UIColor(r: 79, g: 170, b: 248)
    static let darkBlue = UIColor(r: 82, g: 142, b: 200)
    
    convenience init(r: Int, g: Int, b: Int) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1)
    }
    
    convenience init(r: Int, g: Int, b: Int, alpha: CGFloat) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
    
    static var defaultRed: UIColor {
        return UIColor(r: 255, g: 90, b: 95)
    }
    
    static var defaultGray: UIColor {
        return UIColor(r: 118, g: 118, b: 118)
    }
    
    static var defaultBlue: UIColor {
        return UIColor(r: 0, g: 122, b: 255)
    }
    
    static var defaultGreen: UIColor {
        return UIColor(r: 126, g: 204, b: 113)
    }
    
    static var themeColor: UIColor {
        return defaultRed
    }
}
