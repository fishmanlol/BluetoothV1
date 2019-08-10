//
//  Record.swift
//  BluetoothV1
//
//  Created by tongyi on 8/2/19.
//  Copyright © 2019 tongyi. All rights reserved.
//

import Foundation
import UIKit

enum DeviceModel: CaseIterable {
    //contec
    case PM10
    case WT01
    case SpO2
    case TEMP01
    case TEMP03
    case NIBP03
    case NIBP04
    
    static func from(_ name: String) -> DeviceModel? {
        if name.prefix(4) == "PM10" { return .PM10 }
        if name.prefix(4) == "SpO2" { return .SpO2 }
        if name.prefix(4) == "WT01" { return .WT01 }
        if name.prefix(6) == "TEMP01" { return .TEMP01 }
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
        case .TEMP03, .TEMP01:
            return "Thermometer"
        case .NIBP03, .NIBP04:
            return "Blood Pressure Monitor"
        }
    }
    
    var image: UIImage? {
        return UIImage.oximeter
    }
    
    var recordTypes: [Record.RecordType] {
        switch self {
        case .TEMP03, .TEMP01:
            return [.temperature]
        case .NIBP04, .NIBP03:
            return [.systolic, .diastolic, .pulse]
        case .WT01:
            return [.weight]
        default:
            fatalError()
        }
    }
}

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
    
    enum RecordType {
        case temperature
        case diastolic
        case systolic
        case pulse
        case weight
        
        var name: Name {
            switch self {
            case .diastolic:
                return Record.nameOfDiastolic
            case .systolic:
                return Record.nameOfSystolic
            case .pulse:
                return Record.nameOfPulse
            case .temperature:
                return Record.nameOfTemperature
            case .weight:
                return Record.nameOfWeight
            }
        }
        
        var labelImage: UIImage? {
            switch self {
            case .diastolic:
                return UIImage(named: "dia_label")
            case .systolic:
                return UIImage(named: "sys_label")
            case .pulse:
                return UIImage(named: "pulse_label")
            case .temperature, .weight:
                return nil
            }
        }
        
        var unit: String {
            switch self {
            case .diastolic, .systolic:
                return "mmHg"
            case .pulse:
                return "bpm"
            case .temperature:
                return "°F"
            case .weight:
                return "lbs"
            }
        }
    }
    
    enum Level {
        case low
        case slightlyLow
        case normal
        case slightlyHigh
        case high
        case unknown
        
        var symbol: String {
            switch self {
            case .slightlyLow, .low:
                return "↓"
            case .slightlyHigh, .high:
                return "↑"
            case .normal, .unknown:
                return ""
            }
        }
        
        var tintColor: UIColor {
            switch self {
            case .normal:
                return UIColor(r: 38, g: 148, b: 189)
            case .slightlyHigh, .slightlyLow:
                return UIColor(r: 255, g: 165, b: 0)
            case .high, .low:
                return UIColor(r: 255, g: 40, b: 0)
            case .unknown:
                return .gray
            }
        }
    }
    
    let type: RecordType
    var value: Any?
    var name: Name { type.name }
    var labelImage: UIImage? { type.labelImage }
    var level: Level {
        switch type {
        case .diastolic:
            guard let value = value as? Double else { return .unknown }
            if isDiastolicLow(value) { return .low }
            if isDiastolicSlightlyHigh(value) { return .slightlyHigh }
            if isDiastolicHigh(value) { return .high }
            return .normal
        case .systolic:
            guard let value = value as? Double else { return .unknown }
            if isSystolicLow(value) { return .low }
            if isSystolicNormal(value) { return .normal}
            if isSystolicSlightlyHigh(value) { return .slightlyHigh }
            if isSystolicHigh(value) { return .high }
        case .temperature:
            guard let value = value as? Double else { return .unknown }
            if isTemperatureLow(value) { return .low }
            if isTemperatureHigh(value) { return .high }
            return .normal
        case .pulse, .weight:
            return .normal
        }
        fatalError()
    }
}

extension Record {
    static let nameOfTemperature = Name(rawValue: "temperature")
    static let nameOfSystolic = Name(rawValue: "systolic")
    static let nameOfDiastolic = Name(rawValue: "diastolic")
    static let nameOfPulse = Name(rawValue: "pulse")
    static let nameOfWeight = Name(rawValue: "weight")
}

struct Batch {
    var date: Date?
    var records: [Record] = []
    var isEmpty: Bool {
        return records.isEmpty
    }
}


