//
//  CustomObject.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/14/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

class CustomObject: NSObject, Codable, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case age = "age"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(age, forKey: "age")
    }

    required init?(coder aDecoder: NSCoder) {
        if let name = aDecoder.decodeObject(forKey: "name") as? String {
            self.name = name
        }
        if let age = aDecoder.decodeObject(forKey: "age") as? Double {
            self.age = age
        }
    }
    
//    func toDictionary() -> [String: Any] {
////        fatalError("Not Overridden")
//        return ["name": name ?? "No", "age": age ?? -1]
//    }
    
//    override func toData() -> Data? {
//        let encoder = JSONEncoder()
//        return try? encoder.encode(self)
//    }
    
    var name: String?
    var age: Double?
    
    override init() {
        name = ""
        age = 1
    }
    
    init(name: String? = nil, age: Double? = nil) {
        self.name = name
        self.age = age
    }
}
