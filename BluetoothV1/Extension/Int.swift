//
//  Int.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/12/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Int {
    /**
     include bounds: lower <= self <= upper
     */
    func between(_ lower: Int, _ upper: Int) -> Bool {
        return self >= lower && self <= upper
    }
}
