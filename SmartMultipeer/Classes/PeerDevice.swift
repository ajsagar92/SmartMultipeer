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

open class PeerDevice: Device, NSSecureCoding, Hashable {
    
    public static func == (lhs: PeerDevice, rhs: PeerDevice) -> Bool {
        return lhs.deviceID.displayName == rhs.deviceID.displayName
//        return (lhs.deviceID.displayName == rhs.deviceID.displayName && lhs.uuid == rhs.uuid) || (lhs.connectionTime == rhs.connectionTime || lhs.state == rhs.state)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(deviceID.displayName)
//        hasher.combine(uuid)
    }
    
    
    public static var supportsSecureCoding: Bool = true
    
    public func encode(with aCoder: NSCoder) {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.deviceID = MCPeerID(displayName: aDecoder.decodeObject(forKey: "deviceID") as! String)
        self.state = MCSessionState(rawValue: aDecoder.decodeInteger(forKey: "state")) ?? .notConnected
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as? String ?? "Invalid UUID"
        self.connectionTime = aDecoder.decodeObject(forKey: "connectionTime") as? Date
    }
    
    
    public var deviceID: MCPeerID
    public var state: MCSessionState
    public var uuid: String?
    public var connectionTime: Date?
    
    required public init() {
        self.deviceID = MCPeerID(displayName: UIDevice.current.name)
        self.state = .notConnected
        self.uuid = UUID().uuidString
        self.connectionTime = Date()
    }
    
    public init(displayName: String, uuid: String?) {
        self.deviceID = MCPeerID(displayName: displayName)
        self.uuid = uuid
        self.connectionTime = Date()
        self.state = .notConnected
    }
    
    init(withID: String, state: MCSessionState, udid: String?) {
        self.deviceID = MCPeerID(displayName: withID)
        self.state = state
        self.uuid = udid
    }
    
    init(withPeer: MCPeerID, state: MCSessionState, udid: String?) {
        self.deviceID = withPeer
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
