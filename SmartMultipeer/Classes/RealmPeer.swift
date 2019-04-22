//
//  RealmPeer.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/18/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import UIKit
import RealmSwift

class RealmPeer: Object {
    
    @objc dynamic var displayName: String = ""
    @objc dynamic var state: Int = 0
    @objc dynamic var uuid: String?
    @objc dynamic var connectionTime: Date?
    
}
