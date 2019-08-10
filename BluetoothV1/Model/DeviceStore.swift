//
//  DeviceStore.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/9/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

struct DeviceStore {
    
    static var shared = DeviceStore()
    private init() {}
    
    private var devices: [Device] = [Device(model: .TEMP03, name: "TEMP030011", batches: [], peripheral: nil),
                                     Device(model: .NIBP03, name: "NIBP030001", batches: [], peripheral: nil),
                                     Device(model: .WT01, name: "WT014321", batches: [], peripheral: nil)]
    
    public mutating func addDevice(_ device: Device) {
        guard !devices.contains(device) else { return }
        devices.append(device)
    }
    
    public mutating func removeDevice(_ device: Device) {
        devices.removeAll { $0 == device }
    }
    
    public mutating func addBatch(_ batch: Batch, in device: Device) {
        guard let index = devices.firstIndex(of: device) else { return }
        var varDevice = devices[index]
        varDevice.addBatch(batch)
        devices[index] = varDevice
    }
    
    public func getDeviceCount() -> Int {
        return devices.count
    }
    
    public func getDevice(at indexPath: IndexPath) -> Device {
        return devices[indexPath.section]
    }
    
    public func getBatchCount(in device: Device) -> Int {
        guard let index = devices.firstIndex(of: device) else { return 0 }
        return devices[index].batches.count
    }
    
    public func getBatch(at indexPath: IndexPath, in device: Device) -> Batch {
        guard let index = devices.firstIndex(of: device) else { return Batch() }
        return devices[index].batches[indexPath.section]
    }
}
