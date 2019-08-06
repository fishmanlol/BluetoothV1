//
//  DiscoverViewModel.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/2/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//
import Foundation
import UIKit

enum BluetoothStatus {
    case connect, disconnect, unauthorized, unkown
}

class DiscoverViewModel: NSObject {
    private var devices: [Device] = [ Device(model: .PM10, name: "PM103025") ]
    
    var central: CBCentralManager!
    
    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
}

// MARK: - Public functions
extension DiscoverViewModel {
    public func startDiscover() {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopDiscover() {
        central.stopScan()
    }
    
    public func isBluetoothAvailable() -> Bool {
        return central.state == .poweredOn
    }
    
    public func getDeviceCount() -> Int {
        return devices.count
    }
    
    public func configure(_ cell: DeviceCell, with device: Device) {
        cell.deviceIconImageView.image = device.image
        cell.deviceNameLabel.text = device.displayName
        cell.deviceNumberLabel.text = device.number
    }
    
    public func getDevice(at indexPath: IndexPath) -> Device {
        return devices[indexPath.section]
    }
}

// MARK: - CBCentralManager delegate
extension DiscoverViewModel: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            startDiscover()
            Notification.post(name: Notification.bluetoothPoweredOn, object: self)
        case .poweredOff:
            Notification.post(name: Notification.bluetoothPoweredOff, object: self)
        case .unauthorized:
            Notification.post(name: Notification.bluetoothUnauthorized, object: self)
        default:
            Notification.post(name: Notification.bluetoothOtherError, object: self)
        }
    }
    
    //Discover perioheral
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Did discover: \(peripheral.name ?? "")")
        guard let name = peripheral.name, let model = DeviceModel.from(name) else { return }
        Notification.post(name: Notification.didDiscoverPeripheral, object: self, userInfo: ["model": model, "peripheral": peripheral])
    }
}
