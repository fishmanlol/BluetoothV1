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
    
    let vm = DiscoverViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
}

// MARK: - Private functions
extension DiscoverViewController {
    private func setup() {
        view.backgroundColor = .white
        configureNavigationBar()
        configureViews()
    }
    
    private func configureNavigationBar() {
        title = "Vital Sign"
        
        navigationController?.navigationBar.setBackgroundImage(UIImage.from(.white), for: .default)
        navigationController?.navigationBar.titleTextAttributes = [
                                                                    NSAttributedString.Key.foregroundColor: UIColor.darkBlue,
                                                                    NSAttributedString.Key.font: UIFont.avenirNext(bold: .medium, size: UIFont.middleFontSize)]
    }
    
    private func configureViews() {
        let statusBar = StatusBar()
        statusBar.backgroundColor = UIColor.darkBlue
        statusBar.title = "Searching..."
        statusBar.titleColor = UIColor.white
        statusBar.spinColor = UIColor.white
        statusBar.startAnimating()
        self.statusBar = statusBar
        view.addSubview(statusBar)
        
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.register(DeviceCell.self, forCellReuseIdentifier: "DEVICECELL")
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        view.addSubview(tableView)
        
        statusBar.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44)
        }
    }
}

// MARK: - Table view delegate
extension DiscoverViewController: UITableViewDelegate {
    
}

// MARK: - Table view datasource
extension DiscoverViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.getDeviceCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEVICECELL", for: indexPath) as! DeviceCell
        let device = vm.getDevice(at: indexPath)
        vm.configure(cell, with: device)
        return cell
    }
}
