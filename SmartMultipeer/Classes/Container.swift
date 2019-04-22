//
//  Container.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/14/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

class Container: NSObject, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(data, forKey: "data")
        aCoder.encodeCInt(Int32(type.rawValue), forKey: "type")
        aCoder.encode(id, forKey: "id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        if let data = aDecoder.decodeObject(forKey: "data") {
            self.data = data
        }
        else {
            self.data = "Data Decoding Failed"
        }
        
        if let type = Type(rawValue: UInt32(aDecoder.decodeInteger(forKey: "type"))) {
            self.type = type
        }
        else {
            self.type = .String
        }
        
        if let id = aDecoder.decodeObject(forKey: "id") {
            self.id = id
        }
        else {
            self.id = 1
        }
    }
    
    
    var data: Any
    var type: Type
    var id: Any
    
    init(data: Any, ofType: Type, forDataID: Any) {
        self.data = data
        self.type = ofType
        self.id = forDataID
    }
    
}
