//
//  RealmHelper.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/18/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation
import RealmSwift
import MultipeerConnectivity

class RealmHelper: NSObject {
    
    static let instance: RealmHelper = RealmHelper()
    
    //Private
    lazy var realmDB: Realm? = {
        do {
            return try Realm()
        }
        catch let error {
            print("Unable to Initialize Realm   ")
            return nil
        }
    }()

    //MARK: PeerDevice
    //MARK: Realm
    func store(device: PeerDevice) {
        guard let realm = realmDB else {
            print("Unable to Initialize Realm")
            return
        }
        let peer = RealmPeer()
        peer.displayName = device.deviceID.displayName
        peer.state = device.state.rawValue
        peer.uuid = device.uuid
        try? realm.write {
            realm.add(peer)
        }
    }
    
    func getDevicesHistory() -> [PeerDevice] {
        guard let realm = realmDB else {
            print("Unable to Initialize Realm")
            return []
        }
        let peers = Array(realm.objects(RealmPeer.self).sorted(byKeyPath: "displayName", ascending: true))
        
        var devices = [PeerDevice]()
        for peer in peers {
            devices.append(PeerDevice(withID: peer.displayName, state: MCSessionState(rawValue: peer.state) ?? .notConnected, udid: peer.uuid))
        }
        return devices
    }
    
    
    
}
