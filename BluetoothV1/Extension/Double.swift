//
//  Double.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/12/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Double {
    func round(to digit: Int) -> Double {
        guard digit >= 0 else { return self }
        var i = 1
        for _ in 0..<digit {
            i *= 10
        }
        return (self * Double(i)).rounded() / Double(i)
    }
}
