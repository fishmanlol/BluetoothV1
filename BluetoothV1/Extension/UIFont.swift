//
//  UIFont.swift
//  NewStartPart
//
//  Created by Yi Tong on 7/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIFont {
    
    static let largeFontSize: CGFloat = 24
    static let middleFontSize: CGFloat = 17
    static let smallFontSize: CGFloat = 12
    
    static func avenirNext(bold: Bold, size: CGFloat) -> UIFont {
        switch bold {
        case .medium:
            return UIFont(name: "AvenirNext-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:
            return UIFont(name: "AvenirNext-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case .bold:
            return UIFont(name: "AvenirNext-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    enum Bold {
        case regular, medium, bold
    }

    static func menlo(bold: Bold, size: CGFloat) -> UIFont {
        switch bold {
        case .medium, .bold:
            return UIFont(name: "Menlo-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:
            return UIFont(name: "Menlo-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func pingfang(bold: Bold = .regular, size: CGFloat) -> UIFont {
        
        let name: String
        
        switch bold {
        case .regular, .bold:
            name = "PingFangSC-Regular"
        case .medium:
            name = "PingFangSC-Medium"
        }
        
        return UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
