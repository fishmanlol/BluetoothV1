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
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        
        set {
            var f = newValue
            f.origin.x += 20
            f.size.width -= 2 * 20
            super.frame = f
        }
    }
    
    override func awakeFromNib() {
        setup()
    }
}

// MARK: - private functions
extension DeviceCell {
    
    private func setup() {
        deviceNameLabel.font = UIFont.avenirNext(bold: .bold, size: 27)
        deviceIconImageView.contentMode = .scaleAspectFit
        
        addShadow()
    }
    
    private func addShadow() {
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.shadowOpacity = 0.23
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = 4
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
    }
}
