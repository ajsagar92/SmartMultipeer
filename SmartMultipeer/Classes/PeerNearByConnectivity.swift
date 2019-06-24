//
//  MultipeerConnectivity.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public enum User: Int {
    case Host = 1
    case Peer
}

protocol PeerNearByConnectivity {
    
    var service: String { get set }
    
    func setup(withDelegate: DataSyncDelegate, needsPairing: Bool, withCompletionHandler: @escaping(Bool) -> ())
    func connect(forUser: User)
    func sendInvitationForPairing(to: String)
}

extension PeerNearByConnectivity {
    func sendInvitationForPairing(toPeer: PeerDevice) {
        print("You need to implement")
    }
}
