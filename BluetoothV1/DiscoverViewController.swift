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
                                                                    NSAttributedString.Key.font: UIFont.avenirNext(bold: .medium, size: 20)]
    }
    
    private func configureViews() {
        let statusBar = StatusBar()
        statusBar.backgroundColor = UIColor.darkBlue
        statusBar.titleColor = UIColor.white
        statusBar.spinColor = UIColor.white
        statusBar.startAnimating()
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
        tableView.deselectRow(at: indexPath, animated: true)
        present(WaitingViewController(), animated: true, completion: nil)
        if case .hidden = statusBar.status {
            statusBar.status = .working("Searching...")
        } else {
            statusBar.status = .hidden
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
    }
}

// MARK: - Table view datasource
extension DiscoverViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return vm.getDeviceCount()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DEVICECELL", for: indexPath) as! DeviceCell
        let device = vm.getDevice(at: indexPath)
        vm.configure(cell, with: device)
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}
