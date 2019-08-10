//
//  Functions.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/7/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation//98.6

// MARK: - Temperature
func isTemperatureLow(_ temperature: Double) -> Bool {
    return temperature <= 96.0
}

func isTemperatureHigh(_ temperature: Double) -> Bool {
    return temperature >= 100.4
}

// MARK: - Blood pressure
func isSystolicLow(_ value: Double) -> Bool {
    return value < 90
}

func isSystolicNormal(_ value: Double) -> Bool {
    return value >= 90 && value <= 120
}

func isSystolicSlightlyHigh(_ value: Double) -> Bool {
    return value > 120 && value <= 140
}

func isSystolicHigh(_ value: Double) -> Bool {
    return value > 140
}

func isDiastolicLow(_ value: Double) -> Bool {
    return value < 60
}

func isDiastolicNormal(_ value: Double) -> Bool {
    return value >= 60 && value <= 80
}

func isDiastolicSlightlyHigh(_ value: Double) -> Bool {
    return value > 80 && value <= 90
}

func isDiastolicHigh(_ value: Double) -> Bool {
    return value > 90
}
