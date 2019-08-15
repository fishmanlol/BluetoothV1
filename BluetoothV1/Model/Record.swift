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

struct Batch {
    var date: Date?
    var records: [Record] = []
    var isEmpty: Bool {
        return records.isEmpty
    }
    
    func isRedundant(with batch: Batch) -> Bool {
        guard let d1 = date, let d2 = batch.date else { return false }
        return d1 == d2
    }
    
    init(date: Date? = nil, records: [Record] = []) {
        self.date = date
        self.records = records
    }
    
    init?(dict: [AnyHashable: Any]) {
        print(dict)
        //oximeter is different, should be handle separately
        if let oxygenPulse = dict["OxygenPulse"] as? [AnyHashable: Any] {
            print(dict)
            if let data = oxygenPulse["DeviceData1"] as? [[String: Any]], let last = data.last {
                let year = Int(last["year"] as? String ?? "")
                let month = Int(last["month"] as? String ?? "")
                let day = Int(last["day"] as? String ?? "")
                let hour = Int(last["hour"] as? String ?? "")
                let min = Int(last["min"] as? String ?? "")
                let sec = Int(last["sec"] as? String ?? "")
                
                guard let recordDate = Date(year: year, month: month, day: day, hour: hour, min: min, sec: sec) else { return nil }
                date = recordDate
                
                if let pulseString = last["PulseRate"] as? String, let pulse = Double(pulseString) {
                    let record = Record(type: .pulse, value: pulse)
                    records.append(record)
                }
                
                if let oxygenString = last["Oxygen"] as? String, let oxygen = Double(oxygenString) {
                    let record = Record(type: .oxygen, value: oxygen)
                    records.append(record)
                }
                return
            } else {
                return nil
            }
        }
        
        //Other device
        guard let data = dict["DeviceData"] as? [[String: Any]], let last = data.last else { return nil }
        
        //Spirometer is different, f**k
        if let patientInfo = last["PatientInfo"] as? [String: Any], let result = last["TestResult"] as? [String: Any] {
            let year = Int(patientInfo["year"] as? String ?? "")
            let month = Int(patientInfo["month"] as? String ?? "")
            let day = Int(patientInfo["day"] as? String ?? "")
            let hour = Int(patientInfo["hour"] as? String ?? "")
            let min = Int(patientInfo["min"] as? String ?? "")
            let sec = Int(patientInfo["sec"] as? String ?? "")
            guard let recordDate = Date(year: year, month: month, day: day, hour: hour, min: min, sec: sec) else { return nil }
            date = recordDate
            
            if let data = result["unit_L"] as? [String: String] {
//                if let fef25String = data["FEF25"], let fef25 = Double(fef25String) {
//                    let fef25Record = Record(type: .fef25, value: fef25.round(to: 2))
//                    records.append(fef25Record)
//                }
//
//                if let fef2575String = data["FEF2575"], let fef2575 = Double(fef2575String) {
//                    let fef2575Record = Record(type: .fef2575, value: fef2575.round(to: 2))
//                    records.append(fef2575Record)
//                }
//
//                if let fef75String = data["FEF75"], let fef75 = Double(fef75String) {
//                    let fef75Record = Record(type: .fef75, value: fef75.round(to: 2))
//                    records.append(fef75Record)
//                }
                
                if let fev1String = data["FEV1"], let fev1 = Double(fev1String) {
                    let fev1Record = Record(type: .fev1, value: fev1.round(to: 2))
                    records.append(fev1Record)
                }
                
                if let fvcString = data["FVC"], let fvc = Double(fvcString) {
                    let fvcRecord = Record(type: .fvc, value: fvc.round(to: 2))
                    records.append(fvcRecord)
                }
                
                if let pefString = data["PEF"], let pef = Double(pefString) {
                    let pefRecord = Record(type: .pef, value: pef.round(to: 2))
                    records.append(pefRecord)
                }
            }
            
            if records.isEmpty { return nil }
            return
        }
        
        let year = Int(last["year"] as? String ?? "")
        let month = Int(last["month"] as? String ?? "")
        let day = Int(last["day"] as? String ?? "")
        let hour = Int(last["hour"] as? String ?? "")
        let min = Int(last["min"] as? String ?? "")
        let sec = Int(last["sec"] as? String ?? "")
        
        guard let recordDate = Date(year: year, month: month, day: day, hour: hour, min: min, sec: sec) else { return nil }
        date = recordDate
        
        if let weightString = last["Weight"] as? String, let weight = Double(weightString) {
            let transformed = weight * 2.2
            let record = Record(type: .weight, value: transformed.round(to: 1))
            records.append(record)
        }
        
        if let temperatureString = last["temperature"] as? String, let temperature = Double(temperatureString) {
            let transformed = temperature * 1.8 + 32
            let record = Record(type: .temperature, value: transformed.round(to: 1))
            records.append(record)
        }
        
        if let systolicString = last["HighPressure"] as? String, let systolic = Double(systolicString) {
            let record = Record(type: .systolic, value: systolic)
            records.append(record)
        }
        
        if let diastolicString = last["LowPressure"] as? String, let diastolic = Double(diastolicString) {
            let record = Record(type: .diastolic, value: diastolic)
            records.append(record)
        }
        
        if let pulseString = last["PulseRate"] as? String, let pulse = Double(pulseString) {
            let record = Record(type: .pulse, value: pulse)
            records.append(record)
        }
        
        if let oxygenString = last["Oxygen"] as? String, let oxygen = Double(oxygenString) {
            let record = Record(type: .oxygen, value: oxygen)
            records.append(record)
        }
        
        if let bilirubinString = last["BIL"] as? String, let bilirubin = Int(bilirubinString), bilirubin.between(0, 3) {
            let transformed: Double
            if bilirubin == 0 {
                transformed = 0
            } else if bilirubin == 1{
                transformed = 1
            } else if bilirubin == 2 {
                transformed = 3
            } else {
                transformed = 6
            }
            
            let record = Record(type: .bil, value: transformed)
            records.append(record)
        }
        
        if let occultBloodString = last["BLD"] as? String, let occultBlood = Int(occultBloodString), occultBlood.between(1, 4) {
            let transformed: Double
            if occultBlood == 1 {
                transformed = 0.03
            } else if occultBlood == 2 {
                transformed = 0.08
            } else if occultBlood == 3 {
                transformed = 0.15
            } else {
                transformed = 0.75
            }
            
            let record = Record(type: .bld, value: transformed)
            records.append(record)
        }
        
        if let glucoseString = last["GLU"] as? String, let glucose = Int(glucoseString), glucose.between(0, 5) {
            let transformed: Double
            if glucose == 0 {
                transformed = 0
            } else if glucose == 1 {
                transformed = 50
            } else if glucose == 2 {
                transformed = 100
            } else if glucose == 3 {
                transformed = 250
            } else if glucose == 4 {
                transformed = 500
            } else {
                transformed = 1000
            }
            
            let record = Record(type: .glu, value: transformed)
            records.append(record)
        }
        
        if let ketoneString = last["KET"] as? String, let ketone = Int(ketoneString), ketone.between(0, 3) {
            let transformed: Double
            if ketone == 0 {
                transformed = 0
            } else if ketone == 1 {
                transformed = 15
            } else if ketone == 2 {
                transformed = 40
            } else {
                transformed = 80
            }
            
            let record = Record(type: .ket, value: transformed)
            records.append(record)
        }
        
        if let leukocytesString = last["LEU"] as? String, let leukocytes = Int(leukocytesString), leukocytes.between(1, 4) {
            let transformed: Double
            if leukocytes == 1 {
                transformed = 15
            } else if leukocytes == 2 {
                transformed = 70
            } else if leukocytes == 3 {
                transformed = 125
            } else {
                transformed = 500
            }
            
            let record = Record(type: .lue, value: transformed)
            records.append(record)
        }
        
        if let urobilinogenString = last["URO"] as? String, let urobilinogen = Int(urobilinogenString), urobilinogen.between(0, 3) {
            let transformed: Double
            if urobilinogen == 0 {
                transformed = 0.2
            } else if urobilinogen == 1 {
                transformed = 2
            } else if urobilinogen == 2 {
                transformed = 4
            } else {
                transformed = 8
            }
            
            let record = Record(type: .uro, value: transformed)
            records.append(record)
        }
        
        if let proteinString = last["PRO"] as? String, let protein = Int(proteinString), protein.between(0, 4) {
            let transformed: Double
            if protein == 0 {
                transformed = 0
            } else if protein == 1 {
                transformed = 15
            } else if protein == 2 {
                transformed = 30
            } else if protein == 3 {
                transformed = 100
            } else {
                transformed = 300
            }
            
            let record = Record(type: .pro, value: transformed)
            records.append(record)
        }
        
        if let PHString = last["PH"] as? String, let PH = Int(PHString), PH.between(0, 4) {
            let transformed: Double
            if PH == 0 {
                transformed = 5
            } else if PH == 1 {
                transformed = 6
            } else if PH == 2 {
                transformed = 7
            } else if PH == 3 {
                transformed = 8
            } else {
                transformed = 9
            }
            
            let record = Record(type: .ph, value: transformed)
            records.append(record)
        }
        
        if let nitriteString = last["NIT"] as? String, let nitrite = Int(nitriteString), nitrite == 1 {
            let transformed: Double = 0.12
            
            let record = Record(type: .nit, value: transformed)
            records.append(record)
        }
        
        if let specificGravityString = last["SG"] as? String, let specificGravity = Int(specificGravityString), specificGravity.between(0, 5) {
            let tranformed: String
            if specificGravity == 0 {
                tranformed = "≤1.005"
            } else if specificGravity == 1 {
                tranformed = "1.010"
            } else if specificGravity == 2 {
                tranformed = "1.015"
            } else if specificGravity == 3 {
                tranformed = "1.020"
            } else if specificGravity == 4 {
                tranformed = "1.025"
            } else {
                tranformed = "≥1.030"
            }
            
            let record = Record(type: .sg, value: tranformed)
            records.append(record)
        }
        
        if let VCString = last["VC"] as? String, let VC = Int(VCString), VC.between(0, 4) {
            let transformed: Double
            if VC == 0 {
                transformed = 0
            } else if VC == 1 {
                transformed = 10
            } else if VC == 2 {
                transformed = 25
            } else if VC == 3 {
                transformed = 50
            } else {
                transformed = 100
            }
            
            let record = Record(type: .vc, value: transformed)
            records.append(record)
        }
        
        if let heartRateString = last["HeartRate"] as? String, let heartRate = Double(heartRateString) {
            let record = Record(type: .heartRate, value: heartRate)
            records.append(record)
        }
        
        if let ecgData = last["data"] as? [String] {
            let ecg = ecgData.map { Double($0) ?? 16384 } //ECG data is contained in the data array. ECG data range: 0-32767, unit: microvolt(μV), baseline(zero potential) position: 16384
            let record = Record(type: .ecg, value: ecg)
            records.append(record)
        }
        
        if records.isEmpty { return nil }
    }
}



