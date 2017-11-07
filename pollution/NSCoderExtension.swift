//
//  NSCoderExtension.swift
//  pollution
//
//  Created by Philipp Matthes on 07.11.17.
//  Copyright © 2017 Philipp Matthes. All rights reserved.
//

import Foundation

extension NSCoder {
    
    func decodeComplexObject<T>(ofType: T, forKey key: String) -> T? {
        if let decoded = UserDefaults.standard.object(forKey: key) as? NSData {
            if let object = NSKeyedUnarchiver.unarchiveObject(with: decoded as Data) as? T {
                return object
            }
        }
        return nil
    }
    
    func encodeComplex(object: Any, forKey key: String) {
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: object)
        UserDefaults.standard.set(encodedData, forKey: key)
    }
    
}
