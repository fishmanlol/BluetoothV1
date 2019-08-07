//
//  DiscoverViewController.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/2/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit
import SnapKit

class DiscoverViewController: UIViewController {
    weak var tableView: UITableView!
    weak var continueButton: UIButton!
    weak var statusBar: StatusBar!
    
    private var devices: [Device] = [Device(model: .TEMP03, name: "TEMP030011", batches: [], peripheral: nil)]
    var discoveredPeripherals: Set<CBPeripheral> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: - Private functions
extension DiscoverViewController {
    private func setup() {
        view.backgroundColor = .white
        BluetoothManager.shared.addDelegate(self)
        configureNavigationBar()
        configureViews()
    }
    
    private func configureNavigationBar() {
        title = "Vital Sign"
        
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(.white), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [
                                                                    NSAttributedString.Key.foregroundColor: UIColor.darkBlue,
                                                                    NSAttributedString.Key.font: UIFont.avenirNext(bold: .medium, size: 20)]
    }
    
    private func configureViews() {
        let statusBar = StatusBar()
        statusBar.backgroundColor = UIColor.darkBlue
        statusBar.titleColor = UIColor.white
        statusBar.spinColor = UIColor.white
        self.statusBar = statusBar
        view.addSubview(statusBar)
        
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: "DEVICECELL")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        view.addSubview(tableView)
        
        statusBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBar.snp.bottom)
            make.bottom.left.centerX.equalToSuperview()
        }
    }
    
    private func configure(_ cell: DeviceCell, with device: Device) {
        cell.deviceIconImageView.image = device.image
        cell.deviceNameLabel.text = device.displayName
        cell.deviceNumberLabel.text = device.number
    }
    
    private func getDeviceCount() -> Int {
        return devices.count
    }
    
    private func getDevice(at indexPath: IndexPath) -> Device {
        return devices[indexPath.section]
    }
}

// MARK: - Table view delegate
extension DiscoverViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let device = getDevice(at: indexPath)
        let deviceViewController = DeviceViewController(device: device)
        navigationController?.pushViewController(deviceViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
    }
}

// MARK: - Table view datasource
extension DiscoverViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return getDeviceCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEVICECELL", for: indexPath) as! DeviceCell
        let device = getDevice(at: indexPath)
        configure(cell, with: device)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

// MARK: - BluetoothManager delegate
extension DiscoverViewController: BluetoothManagerDelegate {
    func bluetoothManagerDidUpdateState(_ manager: BluetoothManager, _ state: CBManagerState) {
        switch state {
        case .poweredOn:
            statusBar.status = .working("Searching...")
        case .poweredOff:
            statusBar.status = .failed("Please turn on the bluetooth")
            displayAlert(title: "Bluetooth unavailable", msg: "Please make sure your bluetooth turned on", hasCancel: false, action: {})
        case .unauthorized:
            statusBar.status = .failed("Bluetooth is not available")
            displayAlert(title: "Bluetooth unavailable", msg: "Please check your bluetooth setting", hasCancel: false, action: {})
        default:
            statusBar.status = .failed("Bluetooth is not available")
            displayAlert(title: "Bluetooth unavailable", msg: "Please make sure your bluetooth turned on", hasCancel: false, action: {})
        }
    }
    
    func bluetoothDidDiscoverPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print("Did discover: \(peripheral.name ?? "")")
        guard let name = peripheral.name, let model = DeviceModel.from(name) else { return }
        guard !discoveredPeripherals.contains(peripheral) else { return }
        discoveredPeripherals.insert(peripheral)
        
        let device = Device(model: model, name: name)
        let newDeviceViewController = NewDeviceViewController(device: device) {
            BluetoothManager.shared.connect(peripheral)
        }
        
        self.present(newDeviceViewController, animated: true, completion: nil)
    }
    
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print("Did connect: \(peripheral.name ?? "")")
        guard let name = peripheral.name, let model = DeviceModel.from(name) else { return }
        var device = Device(model: model, name: name)
        device.peripheral = peripheral
        devices.append(device)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
