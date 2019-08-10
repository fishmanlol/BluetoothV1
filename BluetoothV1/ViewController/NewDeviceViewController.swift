//
//  NewDeviceViewController.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/5/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class NewDeviceViewController: UIViewController {
    
    @IBOutlet weak var deviceIconBackgroundView: UIView!
    @IBOutlet weak var deviceIconImageView: UIImageView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceNumberLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    let device: Device
    var action: ((Bool) -> Void)?
    
    init(device: Device, action: ((Bool) -> Void)?) {
        self.action = action
        self.device = device
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        action?(false)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        action?(true)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
    }
}

// MARK: - Private
extension NewDeviceViewController {
    private func setup() {
        deviceIconBackgroundView.roundedCorner()
        deviceNameLabel.font = UIFont.avenirNext(bold: .medium, size: UIFont.largeFontSize)
        deviceNumberLabel.font = UIFont.avenirNext(bold: .medium, size: UIFont.middleFontSize)
        addButton.roundedCorner()
        
        deviceNameLabel.text = device.displayName
        deviceNumberLabel.text = device.number
    }
}
