//
//  DataSync.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

public protocol DataSyncDelegate: class {
    
    func sync(dataDidReceive: Any, ofType: Type, at: Date, fromPeer: PeerDevice)
    func update(devices: [PeerDevice], at: Date)
    func lost(device: PeerDevice, at: Date)
    func found(device: PeerDevice, at: Date)
    func disconnect(device: PeerDevice, at: Date)
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any)
    func unpair(from: PeerDevice, at: Date)
}

extension DataSyncDelegate {
    
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any) {
        print("Optional for Acknowledgment")
    }
    
    func lost(device: PeerDevice, at: Date) {
        print("Optional for Lost Device")
    }
    
    func unpair(from: PeerDevice, at: Date) {
        print("Optional for Unpair Device")
    }
    
    func found(device: PeerDevice, at: Date) {
        print("Optional for Found Device")
    }
    
    func disconnect(device: PeerDevice, at: Date) {
        print("Optional for Disconnect Device")
    }
    
}
