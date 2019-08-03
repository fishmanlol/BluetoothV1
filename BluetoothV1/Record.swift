//
//  Record.swift
//  BluetoothV1
//
//  Created by tongyi on 8/2/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation
import UIKit

struct Record {
    let name: String
    var value: Any?
    var time: Date?
}

struct DataDecoder {
    static func decode(_ dict: [String: Any], from device: Device) -> [Record] {
        var records: [Record] = []
        
        switch device.model {
        case .PM10:
            records = decodeFromPM10(dict)
        default:
            break
        }
        
        return records
    }
    
    private static func decodeFromPM10(_ dict: [String: Any]) -> [Record] {
        var records: [Record] = []
        
        return records
    }
}

struct Device {
    let name: String
    let category: DeviceCategory
    let model: DeviceModel
    var brand: Brand?
    var image: UIImage?
    var records: [Record] = []
}

enum DeviceCategory {
    case oximeter
}

enum Brand {
    case contec
}

enum DeviceModel {
    //contec
    case PM10
    case WT01
    case SP10
    
    var identity: String {
        switch self {
        case .PM10:
            return ""
        default:
            return ""
        }
    }
}
