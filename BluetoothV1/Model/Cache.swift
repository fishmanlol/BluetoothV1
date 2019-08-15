//
//  NSCache.swift
//  BluetoothV1
//
//  Created by Yi Tong on 8/14/19.
//  Copyright © 2019 Yi Tong. All rights reserved.
//

import Foundation

struct Cache {
    static let shared = NSCache<NSString, AnyObject>()
        
    static func objectForKey(key: String) -> AnyObject? {
        return shared.object(forKey: key as NSString)
    }
    
    static func setObject(_ object: AnyObject, forKey key: String) {
        shared.setObject(object, forKey: key as NSString)
    }
    
    static func removeObejctForKey(_ key: String) {
        shared.removeObject(forKey: key as NSString)
    }
    
//        - (nullable ObjectType)objectForKey:(KeyType)key;
//    - (void)setObject:(ObjectType)obj forKey:(KeyType)key; // 0 cost
//    - (void)setObject:(ObjectType)obj forKey:(KeyType)key cost:(NSUInteger)g;
//    - (void)removeObjectForKey:(KeyType)key;
}
