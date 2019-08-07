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
    weak var alphaView: UIView!
    
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
        let batch = Batch(date: Date(), records: [Record(name: "Temperature", value: 98.6, time: Date())])
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
        switch device.model {
        case .TEMP03:
            tableView.register(UINib(nibName: "TemperatureCell", bundle: nil), forCellReuseIdentifier: "TEMPERATURECELL")
        default:
            break
        }
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
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        view.addSubview(tableView)
        
        let alphaView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 200, width: view.bounds.width, height: 200))
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = alphaView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor(white: 1, alpha: 0).cgColor]
        gradientLayer.locations = [0.2, 0.8]
        alphaView.layer.addSublayer(gradientLayer)
        self.alphaView = alphaView
        view.addSubview(alphaView)
        
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
            temperatureCell.temperatureLabel.textColor = UIColor.black
            temperatureCell.unitLabel.textColor = UIColor.black
            temperatureCell.timeLabel.text = batch.date?.formattedString
            temperatureCell.temperatureLabel.text = "\(batch.records.first?.value as! Double)"
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 180
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        
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
        let cell: UITableViewCell
        switch device.model {
        case .TEMP03:
            cell = tableView.dequeueReusableCell(withIdentifier: "TEMPERATURECELL", for: indexPath)
        default:
            fatalError()
        }
        
        if getBatchCount() != 0 {
            let batch = device.batches[indexPath.section]
            configure(cell, with: batch)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
