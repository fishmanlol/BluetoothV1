//
//  Functions.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/7/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation//98.6

func isTemperatureLow(_ temperature: Double) -> Bool {
    return temperature <= 96.0
}

func isTemperatureHigh(_ temperature: Double) -> Bool {
    return temperature >= 100.4
}
