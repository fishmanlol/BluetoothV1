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
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
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
        deviceNameLabel.font = UIFont.avenirNext(bold: .medium, size: UIFont.middleFontSize)
        deviceNumberLabel.font = UIFont.avenirNext(bold: .medium, size: UIFont.middleFontSize)
        addButton.roundedCorner()
    }
}
