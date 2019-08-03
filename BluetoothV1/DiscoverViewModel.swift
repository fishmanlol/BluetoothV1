//
//  DiscoverViewModel.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/2/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//
import Foundation
import UIKit

class DiscoverViewModel {
    private var devices: [Device] = [
                                        Device(name: "Oximeter(CM50)", category: .oximeter, model: .PM10, brand: .contec, image: UIImage.oximeter, records: []),
                                        Device(name: "Oximeter(CM51)", category: .oximeter, model: .PM10, brand: .contec, image: UIImage.oximeter, records: []),
                                        Device(name: "Oximeter(CM52)", category: .oximeter, model: .PM10, brand: .contec, image: UIImage.oximeter, records: [])
    ]
}

// MARK: - Public functions
extension DiscoverViewModel {
    public func getDeviceCount() -> Int {
        return devices.count
    }
    
    public func configure(_ cell: DeviceCell, with device: Device) {
        cell.deviceIconImageView.image = device.image
        cell.deviceNameLabel.text = device.name
    }
    
    public func getDevice(at indexPath: IndexPath) -> Device {
        return devices[indexPath.row]
    }
}
