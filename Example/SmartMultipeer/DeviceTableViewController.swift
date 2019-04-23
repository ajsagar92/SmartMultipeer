//
//  DeviceTableViewController.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/18/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class DeviceTableViewController: UITableViewController {
    
    fileprivate var dataSource: [PeerDevice] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = PeerConnectivity.instance.getAllRegisteredDevices()
        self.tableView.reloadData()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceInfoCell", for: indexPath) as! DeviceTableViewCell
        let peer = dataSource[indexPath.row]
        cell.labelDeviceName.text = peer.deviceID.displayName
        
        let peers = PeerConnectivity.instance.connectedPeers.filter({ (device: PeerDevice) -> Bool in
            return peer.deviceID.displayName == device.deviceID.displayName
        })
        cell.labelDeviceState.text = peers.count > 0 ? (peers[0].state == .connected ? "Connected" : "Not Connected") : "Not Connected"

        return cell
    }

}
