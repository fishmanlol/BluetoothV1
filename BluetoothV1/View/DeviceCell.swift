//
//  DeviceCell.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/2/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class DeviceCell: UITableViewCell {
    @IBOutlet weak var deviceNameLabel: UILabel!
    @IBOutlet weak var deviceIconImageView: UIImageView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - private functions
extension DeviceCell {
    private func setup() {
        deviceNameLabel.font = UIFont.avenirNext(bold: .regular, size: UIFont.largeFontSize)
        deviceIconImageView.contentMode = .scaleAspectFit
        
        addShadow()
    }
    
    private func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 5, height: 5 )
        layer.shadowRadius = 4
    }
}
