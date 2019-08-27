//
//  DeviceModel.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/26/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
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
    case BC01
    case PULMO01//PULMO010766
    case PULMO02
    case BG01
    
    static func from(_ name: String) -> DeviceModel? {
        if name.prefix(4) == "PM10" { return .PM10 }
        if name.prefix(4) == "SpO2" { return .SpO2 }
        if name.prefix(4) == "WT01" { return .WT01 }
        if name.prefix(4) == "BC01" { return .BC01}
        if name.prefix(6) == "TEMP01" { return .TEMP01 }
        if name.prefix(6) == "TEMP03" { return .TEMP03 }
        if name.prefix(6) == "NIBP03" { return .NIBP03 }
        if name.prefix(6) == "NIBP04" { return .NIBP04 }
        if name.prefix(7) == "PULMO01" { return .PULMO01 }
        if name.prefix(7) == "PULMO02" { return .PULMO02 }
        if name.prefix(4) == "BG01" || name.hasPrefix("BDE_WEIXIN_TTM") { return .BG01 }
        
        return nil
    }
    
    var displayName: String {
        switch self {
        case .PM10:
            return "ECG"
        case .WT01:
            return "WT01"
        case .SpO2:
            return "Oximeter"
        case .TEMP03, .TEMP01:
            return "Thermometer"
        case .NIBP03, .NIBP04:
            return "Blood Pressure Monitor"
        case .BC01:
            return "Urine Analyzer"
        case .PULMO01, .PULMO02:
            return "Spirometer"
        case .BG01:
            return "Blood Glucose Meter"
            
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
        case .SpO2:
            return [.pulse, .oxygen]
        case .BC01:
            return [.uro, .bld, .bil, .ket, .glu, .pro, .ph, .nit, .lue, .sg, .vc]
        case .PM10:
            return [.heartRate, .ecg]
        case .PULMO01, .PULMO02:
            return [.fvc, .fev1, .pef]
        case .BG01:
            return []
        default:
            fatalError()
        }
    }
}
