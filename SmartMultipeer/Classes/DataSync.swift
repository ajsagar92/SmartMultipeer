//
//  DataSync.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

protocol DataSyncDelegate: class {
    
    func sync(dataDidReceive: Any, ofType: Type, at: Date)
    func update(devices: [PeerDevice], at: Date)
    func lost(device: PeerDevice, at: Date)
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any)
}

extension DataSyncDelegate {
    
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any) {
        print("Optional for Acknowledgment")
    }
    
    func lost(device:PeerDevice, at: Date) {
        print("Optional for Lost Device")
    }
    
}
