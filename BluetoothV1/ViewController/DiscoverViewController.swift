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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BluetoothManager.shared.scan()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BluetoothManager.shared.stopScan()
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
        tableView.register(UINib(nibName: "DeviceCell", bundle: nil), forCellReuseIdentifier: Constant.deviceCell)
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
        
        let device = DeviceStore.shared.getDevice(at: indexPath)
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
        return  DeviceStore.shared.getDeviceCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.deviceCell, for: indexPath) as! DeviceCell
        let device =  DeviceStore.shared.getDevice(at: indexPath)
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
        //exclude the peripherals which in garbage bag the user has declined to connect
        guard !BluetoothManager.shared.isGarbage(peripheral) else { return }
        //exclude the peripherals we don't need
        guard let name = peripheral.name, let model = DeviceModel.from(name) else { return }
        //If this peripheral is a new deivce which not in accept bag, we need pop up a page to make user decide whether connect or not
        if BluetoothManager.shared.isNewDevice(peripheral) {
            let device = Device(model: model, name: name)
            let newDeviceViewController = NewDeviceViewController(device: device) { accpet in
                if accpet {
                    BluetoothManager.shared.connect(peripheral)
                } else {
                    BluetoothManager.shared.addToGarbageBag(peripheral)
                }
            }
            
            self.present(newDeviceViewController, animated: true, completion: nil)
        } else { // Not a new device, in our accept bag
            BluetoothManager.shared.connect(peripheral)
        }
    }
    
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print("Did connect: \(peripheral.name ?? "")")
        guard let name = peripheral.name, let model = DeviceModel.from(name) else { return }
        guard !BluetoothManager.shared.hasAccepted(peripheral) else { return }
        
        BluetoothManager.shared.addToAcceptBag(peripheral)
        
        var device = Device(model: model, name: name)
        device.peripheral = peripheral
         DeviceStore.shared.addDevice(device)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
