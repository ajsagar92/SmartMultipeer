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
    
    func getDevicesHistory(isIncludePaired: Bool = false) -> [PeerDevice] {
        guard let realm = realmDB else {
            print("Unable to Initialize Realm")
            return []
        }
        var peers = Array(realm.objects(RealmPeer.self).sorted(byKeyPath: "displayName", ascending: true))
        if isIncludePaired {
            peers = peers.filter { (peer: RealmPeer) -> Bool in
                peer.isPaired == isIncludePaired
            }
        }
        
        var devices = [PeerDevice]()
        for peer in peers {
            devices.append(PeerDevice(withID: peer.displayName, state: MCSessionState(rawValue: peer.state) ?? .notConnected, udid: peer.uuid))
        }
        return devices
    }
    
    func set(device: String, isPaired: Bool) -> Bool {
        guard let realm = realmDB else {
            print("Unable to Initialize Realm")
            return false
        }
        
        guard let peer = realm.objects(RealmPeer.self).filter("displayName == %@", device).first else {
            return false
        }
        
        do {
            try realm.write {
                peer.isPaired = isPaired
            }
            return true
        }
        catch {
            return false
        }
    }
    
    func getIsPaired(deviceName: String) -> Bool {
        guard let realm = realmDB else {
            print("Unable to Initialize Realm")
            return false
        }
        
        guard let peer = realm.objects(RealmPeer.self).filter("displayName == %@", deviceName).first else {
            return false
        }
        
        return peer.isPaired
    }
    
}
