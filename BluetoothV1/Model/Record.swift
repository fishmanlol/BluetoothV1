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
        case oxygen
        case weight
        case heartRate
        case ecg
        case uro
        case bld
        case bil
        case ket
        case glu
        case pro
        case ph
        case nit
        case lue
        case sg
        case vc
        case fef25
        case fef2575
        case fef75
        case fev1
        case fvc
        case pef
        
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
            case .oxygen:
                return Record.nameOfPulse
            case .bil:
                return Record.nameOfBil
            case .bld:
                return Record.nameOfBld
            case .ket:
                return Record.nameOfKet
            case .glu:
                return Record.nameOfGlu
            case .pro:
                return Record.nameOfPro
            case .ph:
                return Record.nameOfPH
            case .nit:
                return Record.nameOfNit
            case .lue:
                return Record.nameOfLeu
            case .sg:
                return Record.nameOfSg
            case .vc:
                return Record.nameOfVC
            case .uro:
                return Record.nameOfUro
            case .ecg:
                return Record.nameOfEcg
            case .heartRate:
                return Record.nameOfHeartRate
            case .fef25:
                return Record.nameOfFef25
            case .fef2575:
                return Record.nameOfFef2575
            case .fef75:
                return Record.nameOfFef75
            case .fev1:
                return Record.nameOfFev1
            case .fvc:
                return Record.nameOfFvc
            case .pef:
                return Record.nameOfPef
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
            case .oxygen:
                return UIImage(named: "oxygen_label")
            case .temperature, .weight, .ecg:
                return nil
            case .uro:
                return UIImage(named: "uro_label")
            case .bld:
                return UIImage(named: "bld_label")
            case .bil:
                return UIImage(named: "bil_label")
            case .ket:
                return UIImage(named: "ket_label")
            case .glu:
                return UIImage(named: "glu_label")
            case .pro:
                return UIImage(named: "pro_label")
            case .ph:
                return UIImage(named: "ph_label")
            case .nit:
                return UIImage(named: "nit_label")
            case .lue:
                return UIImage(named: "leu_label")
            case .sg:
                return UIImage(named: "sg_label")
            case .vc:
                return UIImage(named: "vc_label")
            case .heartRate:
                return UIImage(named: "heart_rate_label")
            case .fef25:
                return UIImage(named: "fef25_label")
            case .fef2575:
                return UIImage(named: "fef2575_label")
            case .fef75:
                return UIImage(named: "fef75_label")
            case .fev1:
                return UIImage(named: "fev1_label")
            case .fvc:
                return UIImage(named: "fvc_label")
            case .pef:
                return UIImage(named: "pef_label")
            }
        }
        
        var unit: String {
            switch self {
            case .diastolic, .systolic:
                return "mmHg"
            case .pulse, .heartRate:
                return "bpm"
            case .temperature:
                return "°F"
            case .weight:
                return "lbs"
            case .oxygen:
                return "%"
            case .uro, .bld, .bil, .ket, .glu, .pro, .nit, .vc:
                return "mg/dl"
            case .lue:
                return "ul"
            case .ph, .sg, .ecg, .fef25, .fef2575, .fef75, .fev1, .fvc, .pef:
                return ""
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
        case .systolic:
            guard let value = value as? Double else { return .unknown }
            if isSystolicLow(value) { return .low }
            if isSystolicSlightlyHigh(value) { return .slightlyHigh }
            if isSystolicHigh(value) { return .high }
        case .temperature:
            guard let value = value as? Double else { return .unknown }
            if isTemperatureLow(value) { return .low }
            if isTemperatureHigh(value) { return .high }
        case .pulse, .weight, .oxygen, .heartRate, .ecg:
            break
            
        default:
            break
        }
        return .normal
    }
}

extension Record {
    static let nameOfTemperature = Name(rawValue: "temperature")
    static let nameOfSystolic = Name(rawValue: "systolic")
    static let nameOfDiastolic = Name(rawValue: "diastolic")
    static let nameOfPulse = Name(rawValue: "pulse")
    static let nameOfWeight = Name(rawValue: "weight")
    static let nameOfOxygen = Name(rawValue: "oxygen")
    static let nameOfUro = Name(rawValue: "uro")
    static let nameOfBld = Name(rawValue: "bld")
    static let nameOfBil = Name(rawValue: "bil")
    static let nameOfKet = Name(rawValue: "ket")
    static let nameOfGlu = Name(rawValue: "glu")
    static let nameOfPro = Name(rawValue: "pro")
    static let nameOfPH = Name(rawValue: "ph")
    static let nameOfNit = Name(rawValue: "Nit")
    static let nameOfLeu = Name(rawValue: "leu")
    static let nameOfSg = Name(rawValue: "sg")
    static let nameOfVC = Name(rawValue: "vc")
    static let nameOfEcg = Name(rawValue: "ecg")
    static let nameOfHeartRate = Name(rawValue: "heartRate")
    static let nameOfFef25 = Name(rawValue: "fef25")
    static let nameOfFef2575 = Name(rawValue: "fef2575")
    static let nameOfFef75 = Name(rawValue: "fef75")
    static let nameOfFev1 = Name(rawValue: "fev1")
    static let nameOfFvc = Name(rawValue: "fvc")
    static let nameOfPef = Name(rawValue: "Pef")
}



