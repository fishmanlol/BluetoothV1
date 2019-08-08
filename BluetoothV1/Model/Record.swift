//
//  Record.swift
//  BluetoothV1
//
//  Created by tongyi on 8/2/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation
import UIKit

//struct DeviceProfile {
//
//}
//

//
//struct DataDecoder {
//    static func decode(_ dict: [String: Any], from device: Device) -> [Record] {
//        var records: [Record] = []
//
//        switch device.model {
//        case .PM10:
//            records = decodeFromPM10(dict)
//        default:
//            break
//        }
//
//        return records
//    }
//
//    private static func decodeFromPM10(_ dict: [String: Any]) -> [Record] {
//        var records: [Record] = []
//
//        return records
//    }
//}
//
//struct Device {
//    let identity: String
//    let category: DeviceCategory
//    let model: DeviceModel
//    var brand: Brand?
//    var image: UIImage?
//    var batches: [[Date: [Record]]] = []
//}
//
//enum DeviceCategory {
//    case oximeter
//}
//
//enum Brand {
//    case contec
//}

enum DeviceModel: CaseIterable {
    //contec
    case PM10
    case WT01
    case SpO2
    case TEMP03
    case NIBP03
    case NIBP04
    
    static func from(_ name: String) -> DeviceModel? {
        if name.prefix(4) == "PM10" { return .PM10 }
        if name.prefix(4) == "SpO2" { return .SpO2 }
        if name.prefix(4) == "WT01" { return .WT01 }
        if name.prefix(6) == "TEMP03" { return .TEMP03 }
        if name.prefix(6) == "NIBP03" { return .NIBP03 }
        if name.prefix(6) == "NIBP04" { return .NIBP04 }
        
        return nil
    }
    
    var displayName: String {
        switch self {
        case .PM10:
            return "PM10"
        case .WT01:
            return "WT01"
        case .SpO2:
            return "Oximeter"
        case .TEMP03:
            return "Thermometer"
        case .NIBP03, .NIBP04:
            return "Blood Pressure Monitor"
        }
    }
    
    var image: UIImage? {
        return UIImage.oximeter
    }
}

struct Device {
    let model: DeviceModel
    let name: String
    var batches: [Batch] = []
    var peripheral: CBPeripheral?
    
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
        batches.append(batch)
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

struct Record {
    public struct Name: RawRepresentable {
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public var rawValue: String
        
    }
    
    let name: Name
    var value: Any?
}

extension Record {
    static let nameOfTemperature = Name(rawValue: "temperature")
    static let nameOfSystolic = Name(rawValue: "systolic")
    static let nameOfDiastolic = Name(rawValue: "diastolic")
    static let nameOfPulse = Name(rawValue: "pulse")
}

struct Batch {
    var date: Date?
    var records: [Record] = []
}


