//
//  Date.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/6/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

extension Date {
    var formattedString: String {
        if isToday {
            
            return minute > 9 ? "\(hour):\(minute)" : "\(hour):0\(minute)"
        } else {
            return "\(month)/\(day)/\(year)"
        }
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var year: Int {
        return compoments.year ?? 0
    }
    
    var month: Int {
        return compoments.month ?? 0
    }
    
    var day: Int {
        return compoments.day ?? 0
    }
    
    var hour: Int {
        return compoments.hour ?? 0
    }
    
    var minute: Int {
        return compoments.minute ?? 0
    }
    
    var compoments: DateComponents {
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
    }
}
