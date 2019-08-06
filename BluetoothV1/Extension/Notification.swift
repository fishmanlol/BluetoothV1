//
//  Notification.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Notification {
    // MARK: - Bluetooth status notification names
    static let bluetoothPoweredOn: NSNotification.Name = NSNotification.Name(rawValue: "bluetoothPoweredOn")
    static let bluetoothPoweredOff: NSNotification.Name = NSNotification.Name(rawValue: "bluetoothPoweredOff")
    static let bluetoothUnauthorized: NSNotification.Name = NSNotification.Name(rawValue: "bluetoothUnauthorized")
    static let bluetoothOtherError: NSNotification.Name = NSNotification.Name(rawValue: "bluetoothOtherError")
    
    // MARK: - Peripheral notification name
    static let didDiscoverPeripheral: NSNotification.Name = NSNotification.Name(rawValue: "didDiscoverPeripheral")
    
    static func post(name: NSNotification.Name, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    static func addObserver(_ observer: Any, selector: Selector, name: NSNotification.Name, object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
}
