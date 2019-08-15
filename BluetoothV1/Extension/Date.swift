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
    
    init?(year: Int?, month: Int?, day: Int?, hour: Int?, min: Int?, sec: Int?) {
        
        guard let year = year, let month = month, let day = day, let hour = hour, let min = min, let sec = sec else { return nil }
        
        let calendar = Calendar.current
        let timeZone = TimeZone.current
        
        let components = DateComponents(calendar: calendar, timeZone: timeZone, era: nil, year: year, month: month, day: day, hour: hour, minute: min, second: sec, nanosecond: nil, weekday: nil, weekdayOrdinal: nil, quarter: nil, weekOfMonth: nil, weekOfYear: nil, yearForWeekOfYear: nil)
        if let date = components.date {
            self = date
        } else {
            return nil
        }
    }
}
