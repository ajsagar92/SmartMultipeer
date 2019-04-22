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
        var unarchivedObject: Container? = nil
        do {
            unarchivedObject = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(self) as? Container
            
        } catch {
            fatalError("Unable to Unarchive")
        }
        return unarchivedObject
    }
    
    /// Converts an object into Data using NSKeyedArchiver
    static func toData(object: Container) -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
        }
        catch let error {
            print(error.localizedDescription)
        }
        return nil
    }
    
}
