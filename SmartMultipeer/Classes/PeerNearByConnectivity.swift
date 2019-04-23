//
//  MultipeerConnectivity.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation
import MultipeerConnectivity

enum User: Int {
    case Host = 1
    case Peer
}

protocol PeerNearByConnectivity {
    
    var service: String { get set }
    
    func setup(withInvitation: Bool, toListPeers: Bool)
    func connect(for: User)
    
}

extension PeerNearByConnectivity {
    
    func setup(withInvitation: Bool = false, toListPeers: Bool = false) {}
    func connect(for: User) {}
    
}
