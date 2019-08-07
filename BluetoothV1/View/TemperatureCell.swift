//
//  TemperatureCell.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/6/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import UIKit

class TemperatureCell: UITableViewCell {
    
//    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var unitLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
    }
    
    
}
