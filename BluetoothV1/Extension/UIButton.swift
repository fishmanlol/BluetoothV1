//
//  UIButton.swift
//  BluetoothV1
//
//  Created by tongyi on 8/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

extension UIButton {
    override func roundedCorner() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}
