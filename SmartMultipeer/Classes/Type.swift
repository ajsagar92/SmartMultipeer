//
//  DataType.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

public enum Type: UInt32 {
    case Int = 1
    case Double
    case String
    case Image
    case Dictionary
    case Array
    case Custom
    case CustomArray
    
    case Disconnect
    case Unpair
    case Acknowledge
    
    static func getType(type: Type) -> UInt32 {
        return type.rawValue
    }
}
