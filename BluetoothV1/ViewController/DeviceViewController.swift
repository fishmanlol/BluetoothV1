//
//  DeviceViewController.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class DeviceViewController: UIViewController {
    weak var tableView: UITableView!
    weak var fetchButton: UIButton!
    weak var statusBar: StatusBar!
    
    private var device: Device
    
    init(device: Device) {
        self.device = device
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateStatusBar()
    }
    
    @objc func fetchButtonTapped(sender: UIButton) {
        guard BluetoothManager.shared.isBluetoothAvailable() else {
            displayAlert(msg: Constant.bluetoothIsNotAvailable)
            return
        }
        
        guard let peripheralState = device.peripheral?.state else {
            displayAlert(msg: Constant.unkownError)
            return
        }
        
        guard peripheralState == .connected else {
            displayAlert(title: nil, msg: Constant.deviceNotConncted)
            return
        }
        
        
        //fake data
        let batch: Batch
        switch device.model {
        case .TEMP03, .TEMP01:
            let randomTemperature = Double.random(in: ClosedRange(uncheckedBounds: (lower: 90, upper: 110))).rounded()
            batch = Batch(date: Date(), records: [Record(type: .temperature, value: randomTemperature)])
        case .NIBP03, .NIBP04:
            batch = Batch(date: Date(), records: [Record(type: .systolic, value: 121.0), Record(type: .diastolic, value: 80.0), Record(type: .pulse, value: 72.0)])
        case .WT01:
            let randomWeight = Double.random(in: ClosedRange(uncheckedBounds: (lower: 60, upper: 150))).rounded()
            batch = Batch(date: Date(timeInterval: -500000, since: Date()), records: [Record(type: .weight, value: randomWeight), Record(type: .weight, value: randomWeight)])
        default:
            fatalError()
        }

         DeviceStore.shared.addBatch(batch, in: device)
        tableView.reloadData()
    }
    
    deinit {
        BluetoothManager.shared.removeDelegate(self)
    }
}

// MARK: - Private functions
extension DeviceViewController {
    private func setup() {
        BluetoothManager.shared.addDelegate(self)
        view.backgroundColor = .white
        configureNavigationBar()
        configureViews()
    }
    
    private func configureNavigationBar() {
        title = device.displayName
        
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
        tableView.register(BatchCell.self, forCellReuseIdentifier: Constant.batchCell)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        view.addSubview(tableView)
        
        let fetchButton = UIButton(type: .system)
        fetchButton.setTitle("Fetch", for: .normal)
        fetchButton.roundedCorner()
        fetchButton.setBackgroundImage(UIImage.from(.darkBlue), for: .normal)
        fetchButton.setTitleColor(.white, for: .normal)
        fetchButton.addTarget(self, action: #selector(fetchButtonTapped), for: .touchUpInside)
        self.fetchButton = fetchButton
        view.addSubview(fetchButton)
        
        statusBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0)
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBar.snp.bottom)
            make.left.centerX.equalToSuperview()
            make.bottom.equalTo(fetchButton.snp.top)
        }
        
        fetchButton.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            } else {
                make.bottom.equalToSuperview().offset(-30)
            }
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(min(view.bounds.width * 0.75, 300))
        }
    }
    
    
    private func updateStatusBar() {
        if BluetoothManager.shared.isBluetoothAvailable() {
            guard let peripheral = device.peripheral else {
                statusBar.status = .failed(Constant.unkownError)
                return
            }
            
            switch peripheral.state {
            case .connected:
                statusBar.status = .succeed(Constant.deviceConncted)
            case .connecting:
                statusBar.status = .working(Constant.deviceConnecting)
            default:
                BluetoothManager.shared.connect(peripheral)
                statusBar.status = .working(Constant.deviceSearch)
            }
            
        } else {
            
            statusBar.status = .failed(Constant.bluetoothIsNotAvailable)
        }
    }
}

// MARK: - Table view delegate
extension DeviceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
    }
}

// MARK: - Table view datasource
extension DeviceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let batchCount = DeviceStore.shared.getBatchCount(in: device)
        return batchCount == 0 ? 1 : batchCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.batchCell, for: indexPath) as! BatchCell
        if DeviceStore.shared.getBatchCount(in: device) != 0 {
            let batch = DeviceStore.shared.getBatch(at: indexPath, in: device)
            cell.configure(with: batch, for: device.model)
        } else {
            cell.configure(with: Batch(), for: device.model)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

// MARK: - Bluetooth manager delegate
extension DeviceViewController: BluetoothManagerDelegate {
    func bluetoothManagerDidUpdateState(_ manager: BluetoothManager, _ state: CBManagerState) {
        switch state {
        case .poweredOn:
            statusBar.status = .working(Constant.deviceSearch)
        default:
            statusBar.status = .failed(Constant.bluetoothIsNotAvailable)
        }
    }
    
    func bluetoothDidDiscoverPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print(#function)
    }
    
    func bluetoothDidConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print(#function)
        statusBar.status = .succeed(Constant.deviceConncted)
    }
    
    func bluetoothDidDisconnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print(#function)
        manager.connect(peripheral)
        statusBar.status = .working(Constant.deviceSearch)
    }
    
    func bluetoothDidFailToConnectPeripheral(_ manager: BluetoothManager, _ peripheral: CBPeripheral) {
        print(#function)
        manager.connect(peripheral)
        statusBar.status = .working(Constant.deviceSearch)
    }
}
