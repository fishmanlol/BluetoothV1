//
//  UIView.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIView {
    @objc func roundedCorner() {
        layer.cornerRadius = 0.5 * bounds.height
        layer.masksToBounds = true
    }
}
