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
}

//Default implementation
extension BluetoothManagerDelegate {
    func bluetoothDidDiscoverPeripheral(_ peripheral: CBPeripheral) {}
}

class BluetoothManager: NSObject {
    
    private var central: CBCentralManager!
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    /**
     Singleton
     */
    static let shared: BluetoothManager = BluetoothManager()
    override init() {
        super.init()
        self.central = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    //Public functions
    public func connect(_ peripheral: CBPeripheral) {
        central.connect(peripheral, options: nil)
    }
    
    public func isBluetoothAvailable() -> Bool {
        return central.state == .poweredOn
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
