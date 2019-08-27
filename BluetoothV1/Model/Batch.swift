//
//  Batch.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/26/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

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
