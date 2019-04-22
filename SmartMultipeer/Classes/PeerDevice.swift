//
//  Device.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class PeerDevice: Device, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    func encode(with aCoder: NSCoder) {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.deviceID = MCPeerID(displayName: aDecoder.decodeObject(forKey: "deviceID") as! String)
        self.state = MCSessionState(rawValue: aDecoder.decodeInteger(forKey: "state")) ?? .notConnected
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String ?? "Invalid UUID"
        self.connectionTime = aDecoder.decodeObject(forKey: "connectionTime") as? Date
    }
    
    
    var deviceID: MCPeerID
    var state: MCSessionState
    var uuid: String?
    var connectionTime: Date?
    
    required init() {
        self.deviceID = MCPeerID(displayName: UIDevice.current.name)
        self.state = .notConnected
        self.uuid = UUID().uuidString
        self.connectionTime = Date()
    }
    
    init(withID: String, state: MCSessionState, udid: String?) {
        self.deviceID = MCPeerID(displayName: withID)
        self.state = state
        self.uuid = udid
    }
}

protocol Device {
    
    var deviceID: MCPeerID { get }
    var state: MCSessionState { get set }
    
    func getDeviceType() -> String
    func getDeviceName() -> String
}

extension Device {
    
    func getDeviceType() -> String {
        return UIDevice.current.model
    }
    
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
}
