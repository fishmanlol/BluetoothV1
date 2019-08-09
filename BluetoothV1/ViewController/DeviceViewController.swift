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
        //fake data
        let batch: Batch
        switch device.model {
        case .TEMP03:
            let randomTemperature = Double.random(in: ClosedRange(uncheckedBounds: (lower: 90, upper: 110))).rounded()
            batch = Batch(date: Date(), records: [Record(type: .temperature, value: randomTemperature)])
        case .NIBP03, .NIBP04:
            batch = Batch(date: Date(), records: [Record(type: .systolic, value: 141.0), Record(type: .diastolic, value: 80.0), Record(type: .pulse, value: 72.0)])
        default:
            fatalError()
        }

        device.addBatch(batch)
        tableView.reloadData()
    }
}

// MARK: - Private functions
extension DeviceViewController {
    private func setup() {
        view.backgroundColor = .white
        configureNavigationBar()
        configureViews()
        registerCell()
    }
    
    private func registerCell() {
        tableView.register(BatchCell.self, forCellReuseIdentifier: "BATCHCELL")
//        switch device.model {
//        case .TEMP03:
////            tableView.register(UINib(nibName: "TemperatureCell", bundle: nil), forCellReuseIdentifier: "TEMPERATURECELL")
//            tableView.register(BatchCell.self, forCellReuseIdentifier: "BATCHCELL")
//        case .NIBP03, .NIBP04:
//            tableView.register(UINib(nibName: "BloodPressureCell", bundle: nil), forCellReuseIdentifier: "BLOODPRESSURECELL")
//        default:
//            fatalError()
//        }
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
    
    private func configure(_ cell: UITableViewCell, with batch: Batch) {
        switch device.model {
        case .TEMP03:
            guard let temperatureCell = cell as? TemperatureCell else { return }
            guard let temperatureValue = batch.records.first?.value as? Double else { return }
            temperatureCell.timeLabel.text = batch.date?.formattedString
            temperatureCell.temperatureLabel.text = "\(temperatureValue)"
            
            if isTemperatureLow(temperatureValue) {
                temperatureCell.temperatureLabel.textColor = UIColor(r: 38, g: 148, b: 189)
                temperatureCell.unitLabel.textColor = UIColor(r: 38, g: 148, b: 189)
            } else if isTemperatureHigh(temperatureValue) {
                temperatureCell.temperatureLabel.textColor = UIColor(r: 255, g: 40, b: 0)
                temperatureCell.unitLabel.textColor = UIColor(r: 255, g: 40, b: 0)
            } else {
                temperatureCell.temperatureLabel.textColor = .black
                temperatureCell.unitLabel.textColor = .black
            }
            
            
        case .NIBP03, .NIBP04:
            guard let bloodPressureCell = cell as? BloodPressureCell else { return }
            bloodPressureCell.timeLabel.text = batch.date?.formattedString
            for record in batch.records {
                if record.name == Record.nameOfSystolic, let systolicValue = record.value as? Double {
                    bloodPressureCell.sysLabel.textColor = .black
                    bloodPressureCell.sysLabel.text = "\(systolicValue)"
                    continue
                }
                
                if record.name == Record.nameOfDiastolic, let diastolicValue = record.value as? Double {
                    bloodPressureCell.diaLabel.textColor = .black
                    bloodPressureCell.diaLabel.text = "\(diastolicValue)"
                    continue
                }
                
                if record.name == Record.nameOfPulse, let pulseValue = record.value as? Double {
                    bloodPressureCell.pulseLabel.textColor = .black
                    bloodPressureCell.pulseLabel.text = "\(pulseValue)"
                    continue
                }
            }
        default:
            fatalError()
        }
    }
    
    private func getBatchCount() -> Int {
        return device.batches.count
    }
    
    private func getBatch(at indexPath: IndexPath) -> Batch {
        return device.batches[indexPath.section]
    }
    
    private func updateStatusBar() {
        if BluetoothManager.shared.isBluetoothAvailable() {
            guard let peripheral = device.peripheral else {
                statusBar.status = .failed("Unkown Error")
                return
            }
            
            switch peripheral.state {
            case .connected:
                statusBar.status = .succeed("Device is connected")
            case .connecting:
                statusBar.status = .succeed("Device is connecting")
            default:
                statusBar.status = .succeed("Device is disconnected")
            }
            
        } else {
            statusBar.status = .failed("Bluetooth is not available")
        }
    }
}

// MARK: - Table view delegate
extension DeviceViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        switch device.model {
//        case .TEMP03:
//            return 180
//        case .NIBP03, .NIBP04:
//            return 260
//        default:
//            fatalError()
//        }
//    }
    
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
        return getBatchCount() == 0 ? 1 : getBatchCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BATCHCELL", for: indexPath) as! BatchCell
        if getBatchCount() != 0 {
            let batch = device.batches[indexPath.section]
            cell.configure(with: batch, for: device.model)
        } else {
            cell.configure(with: Batch(), for: device.model)
        }
        
        return cell
        
//        switch device.model {
//        case .TEMP03:
////            cell = tableView.dequeueReusableCell(withIdentifier: "TEMPERATURECELL", for: indexPath)
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BATCHCELL", for: indexPath) as! BatchCell
//
//            if getBatchCount() != 0 {
//                let batch = device.batches[indexPath.section]
//                cell.configure(with: batch, for: device.model)
//            } else {
//                cell.configure(with: Batch(), for: device.model)
//            }
//
//            return cell
//        case .NIBP03, .NIBP04:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "BLOODPRESSURECELL", for: indexPath)
//            if getBatchCount() != 0 {
//                let batch = device.batches[indexPath.section]
//                configure(cell, with: batch)
//            }
//            return cell
//        default:
//            fatalError()
//        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
