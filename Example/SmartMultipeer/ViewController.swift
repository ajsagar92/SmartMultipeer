//
//  ViewController.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import UIKit
import SmartMultipeer

class ViewController: UIViewController, DataSyncDelegate {
    
    @IBOutlet weak var connectedDevices: UILabel!
    @IBOutlet weak var textFieldDataSync: UITextField!
    @IBOutlet weak var dataSyncTableView: UITableView!
    
    fileprivate var isSetupDone = false
    fileprivate var sections = 1
    
    var peersConnected: [PeerDevice] = []
    var devicesAcknowledged: Dictionary<String, Dictionary<Int, Bool>> = Dictionary()
    
    var orderToPostReceived = [OrderToPost]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSyncTableView.dataSource = self
    }
    
    @IBAction func reconnect(_ sender: Any) {
        PeerConnectivity.instance.disconnect()
        setup()
        if peersConnected.count == 0 {
            let alertController = UIAlertController(title: "Connectivity", message: "Connection Build Failed", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func syncDevice(_ sender: Any) {
        if !isSetupDone {
            setup()
        }
        dataSyncTableView.reloadData()
        guard let dataToSend = textFieldDataSync.text, dataToSend.count > 0 else {
            let alertController = UIAlertController(title: "Data Sync Error", message: "Nothing to Sync", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        guard let custom = TemplateOrderToPost.getOrder(orderID: Int64(dataToSend) ?? -1) else {
            print("Order Not Parsed from File")
            return
        }
        PeerConnectivity.instance.send(data: custom, ofType: Type.Custom, withID: custom.orderID)
    }
    
    func setup() {
        if !isSetupDone {
            PeerConnectivity.instance.service = "sample-service"
            PeerConnectivity.instance.setup(fromViewController: self, withDelegate: self)
            isSetupDone = true
        }
        
        dataSyncTableView.reloadData()
        initializePeer()
        initializeHost()
    }
    
    func initializeHost() {
        PeerConnectivity.instance.connect(forUser: .Host)
    }
    
    func initializePeer() {
        PeerConnectivity.instance.connect(forUser: .Peer)
    }
    
    //MARK: Delgate Peer Connectivity
    func sync(dataDidReceive: Any, ofType: Type, at: Date) {
        switch ofType {
            case .Custom:
                guard let customObject = dataDidReceive as? OrderToPost else {
                    print("Invalid Object Conversion")
                    return
                }
                orderToPostReceived.append(customObject)
                sections = 1
                dataSyncTableView.reloadData()
            
            default:
            break
        }
    }
    
    func update(devices: [PeerDevice], at: Date) {
        peersConnected = devices
        var devicesText = ""
        for device in devices {
            devicesText = devicesText.count > 0 ? "\(devicesText),  \(device.deviceID.displayName)" : device.deviceID.displayName
        }
        connectedDevices.text = devices.count > 0 ? devicesText : "No Device"
    }
    
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any) {
        print("Acknowledged \(from.deviceID.displayName), for data: \(forDataID)")
        var orderDictionary = devicesAcknowledged[from.deviceID.displayName] ?? Dictionary()
        orderDictionary [(forDataID as? Int ?? 1)] = true
        devicesAcknowledged[from.deviceID.displayName] = orderDictionary
        sections = 2
        dataSyncTableView.reloadData()
    }
    
    func lost(device: PeerDevice, at: Date) {
        
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return orderToPostReceived.count
            default:
                return peersConnected.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 0:
                return "Data"
            
            default:
                return "Device"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
            case 0:
                guard let dataCell = tableView.dequeueReusableCell(withIdentifier: "dataCell") else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "dataCell")
                
                    let customObject = orderToPostReceived[indexPath.row]
                
                    cell.textLabel?.text = "\(String(describing: customObject.orderID)), \(String(describing: customObject.transactionNo)), \(String(describing: customObject.orderNo)), \(customObject.offlineUniqueID), \(String(describing: customObject.orderReferenceID)), \(customObject.authenticatedCode)"
                    cell.detailTextLabel?.text = "OrderItem: \(customObject.orderItems[0].name), \(customObject.orderItems[1].name)"
                
                    return cell
                }
                return dataCell
            
            default:
                guard let deviceCell = tableView.dequeueReusableCell(withIdentifier: "deviceCell") else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "deviceCell")
                    return cell
                    
                }
                update(cell: deviceCell, indexPath: indexPath)
                return deviceCell
        }
    }
    
    private func update(cell: UITableViewCell, indexPath: IndexPath) {
        let peerName = peersConnected[indexPath.row].deviceID.displayName
        cell.textLabel?.text = peerName
        
        let orders = Array((devicesAcknowledged[peersConnected[indexPath.row].deviceID.displayName] ?? Dictionary()).keys)
        
        var orderReceived = ""
        for orderId in orders {
            let orderStatus = (devicesAcknowledged[peersConnected[indexPath.row].deviceID.displayName] ?? Dictionary())[orderId] == true ? "\(orderId): Received" : "Not Received"
            orderReceived = orderReceived.count > 0 ? "\(orderReceived), \(orderStatus)" : orderStatus
        }
        cell.detailTextLabel?.text = orderReceived
    }
}

