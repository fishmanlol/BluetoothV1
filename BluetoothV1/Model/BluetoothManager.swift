//
//  BluetooManager.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/6/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

protocol BluetoothManagerDelegate: class {
    func bluetoothManagerDidUpdateState(_ manager: BluetoothManager, _ state: CBManagerState)
    func bluetoothDidDiscoverPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral)
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral)
    func bluetoothDidFailToConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral)
    func bluetoothDidDisconnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral)
    func bluetoothWillFetchData(_ manager: BluetoothManager, from peripheral: CBPeripheral)
    func bluetoothDidReceivedData(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ batch: Batch)
    func bluetoothDidFetchDataError(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ message: String)
}

//Default implementation
extension BluetoothManagerDelegate {
    func bluetoothDidDiscoverPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {}
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {}
    func bluetoothDidFailToConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {}
    func bluetoothDidDisconnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {}
    func bluetoothWillFetchData(_ manager: BluetoothManager, from peripheral: CBPeripheral) {}
    func bluetoothDidReceivedData(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ batch: Batch) {}
    func bluetoothDidFetchDataError(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ message: String) {}
}

class BluetoothManager: NSObject {
    private var central: CBCentralManager!
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    private var acceptBag: Set<CBPeripheral> = []
    private var garbageBag: Set<CBPeripheral> = []
    private var command: DeviceCommand = DeviceCommand()
    private var fetchingPeripheral: CBPeripheral?
    
    /**
     Singleton
     */
    static let shared: BluetoothManager = BluetoothManager()
    override init() {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: nil, options: nil)
        self.command.delegate = self
    }
    
    //Public functions
    var isFetching: Bool {
        return fetchingPeripheral != nil
    }
    
    public func fetchData(from device: Device) {
        guard let peripheral = device.peripheral else { return }
        fetchingPeripheral = peripheral
        bluetoothWillFetchData(self, from: peripheral)
        command.peripheral(peripheral, receiveData: 1)
    }
    
    public func isNewDevice(_ peripheral: CBPeripheral) -> Bool {
        return !acceptBag.contains(peripheral) && !garbageBag.contains(peripheral)
    }
    
    public func hasAccepted(_ peripheral: CBPeripheral) -> Bool {
        return acceptBag.contains(peripheral)
    }
    
    public func isGarbage(_ peripheral: CBPeripheral) -> Bool {
        return garbageBag.contains(peripheral)
    }
    
    public func addToAcceptBag(_ peripheral: CBPeripheral) {
        acceptBag.insert(peripheral)
    }
    
    public func addToGarbageBag(_ peripheral: CBPeripheral) {
        garbageBag.insert(peripheral)
    }
    
    public func emptyGarbageBag() {
        garbageBag.removeAll()
    }
    
    public func scan() {
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    
    public func stopScan() {
        central.stopScan()
    }
    
    public func connect(_ peripheral: CBPeripheral) {
        central.connect(peripheral, options: nil)
    }
    
    public func isBluetoothAvailable() -> Bool {
        return central.state == .poweredOn
    }
    
    private func deleteData(from peripheral: CBPeripheral) {
        command.peripheral(peripheral, deleteData: 0)
    }
}

// MARK: - Delegate
extension BluetoothManager {
    func addDelegate(_ delegate: BluetoothManagerDelegate) {
        delegates.add(delegate)
    }
    
    func removeDelegate(_ delegate: BluetoothManagerDelegate) {
        for d in delegates.allObjects.reversed() {
            if delegate === d {
                delegates.remove(d)
                return
            }
        }
    }

    //Delegate functions
    func bluetoothManagerDidUpdateState(_ manager: BluetoothManager, _ state: CBManagerState) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothManagerDidUpdateState(manager, state)
        }
    }
    
    func bluetoothDidDiscoverPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidDiscoverPeripheral(manager, peripheral)
        }
    }
    
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidConnectPeripheral(manager, peripheral)
        }
    }
    
    func bluetoothDidFailToConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidFailToConnectPeripheral(manager, peripheral)
        }
    }
    
    func bluetoothDidDisconnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidDisconnectPeripheral(manager, peripheral)
        }
    }
    
    func bluetoothWillFetchData(_ manager: BluetoothManager, from peripheral: CBPeripheral) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothWillFetchData(manager, from: peripheral)
        }
    }
    
    func bluetoothDidReceivedData(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ batch: Batch) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidReceivedData(manager, from: peripheral, batch)
        }
    }
    
    func bluetoothDidFetchDataError(_ manager: BluetoothManager, from peripheral: CBPeripheral, _ message: String) {
        for delegate in delegates.allObjects.reversed() {
            (delegate as! BluetoothManagerDelegate).bluetoothDidFetchDataError(manager, from: peripheral, message)
        }
    }
}

// MARK: - CBCentralManager delegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if case .poweredOn = central.state {
            central.scanForPeripherals(withServices: nil, options: nil)
        }
        
        bluetoothManagerDidUpdateState(self, central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        bluetoothDidDiscoverPeripheral(self, peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        bluetoothDidConnectPeripheral(self, peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        bluetoothDidFailToConnectPeripheral(self, peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        bluetoothDidDisconnectPeripheral(self, peripheral)
    }
}

// MARK: - Device command delegate
extension BluetoothManager: DeviceCommandDelegate {
    func getDeviceData(_ dicDeviceData: [AnyHashable : Any]!) {
        guard let peripheral = fetchingPeripheral else { return }
        fetchingPeripheral = nil
        if let batch = Batch(dict: dicDeviceData) {
            print(batch)
            bluetoothDidReceivedData(self, from: peripheral, batch)
//            deleteData(from: peripheral)
        } else {
            bluetoothDidFetchDataError(self, from: peripheral, "Please re-measure your vital sign")
        }
    }
    
    func getOperateResult(_ dicOperateResult: [AnyHashable : Any]!) {
        print(#function)
    }
    
    func getError(_ dicError: [AnyHashable : Any]!) {
        guard let peripheral = fetchingPeripheral else { return }
        fetchingPeripheral = nil
        print(#function)
        bluetoothDidFetchDataError(self, from: peripheral, "Fetch data error, try again later")
    }
}

// MARK: - Others
/**
 An array wrapper does not hold strong reference of inside elements
 */
struct WeakArray<Element: AnyObject> {
    private var elements: [WeakBox<Element>]
    
    init(_ elements: [Element]) {
        self.elements = elements.map { WeakBox<Element>($0) }
    }
}

extension WeakArray: Collection {
    var startIndex: Int { return elements.startIndex }
    var endIndex: Int { return elements.endIndex }
    
    subscript(_ index: Int) -> Element? {
        guard index >= startIndex && index < endIndex else { return nil }
        
        return elements[index].value
    }
    
    func index(after i: Int) -> Int {
        return elements.index(after: i)
    }
}

/**
 A wrapper does not hold strong reference of inside element
 */
final class WeakBox<A: AnyObject> {
    weak var value: A?
    init(_ value: A) {
        self.value = value
    }
}
