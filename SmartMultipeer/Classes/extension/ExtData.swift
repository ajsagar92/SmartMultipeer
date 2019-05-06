//
//  ExtensionData.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/4/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

extension Data {
    
    func convert() -> Container? {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as? Container
    }
    
    /// Converts an object into Data using NSKeyedArchiver
    public static func toData(object: Container) -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
}
