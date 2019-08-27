//
//  Device.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/26/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation
import UIKit

struct Device {
    let model: DeviceModel
    let name: String
    var batches: [Batch] = []
    var peripheral: CBPeripheral?
    
    init(model: DeviceModel, name: String, batches: [Batch] = [], peripheral: CBPeripheral? = nil) {
        self.model = model
        self.name = name
        self.batches = batches
        self.peripheral = peripheral
    }
    
    var displayName: String {
        return model.displayName
    }
    
    var image: UIImage? {
        return model.image
    }
    
    var number: String {
        return "#" + String(name.suffix(4))
    }
    
    mutating func addBatch(_ batch: Batch) {
        batches.insert(batch, at: 0)
    }
}

extension Device: Hashable {
    static func == (lhs: Device, rhs: Device) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
