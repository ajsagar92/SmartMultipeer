//
//  PeerConnectivity.swift
//  MultipeerConnectivity
//
//  Created by Ajay Sagar Parwani on 4/2/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import RealmSwift

open class PeerConnectivity: NSObject, PeerNearByConnectivity {
    
    public static let instance = PeerConnectivity()
    
    var connectionTimeOut = 10.0
    
    //Advertising with No Invitation
    fileprivate var serviceAdvertiser: MCNearbyServiceAdvertiser?
    
    //Browsing Peers
    fileprivate var serviceBrowser: MCNearbyServiceBrowser?
    
    //Send / Receive Data Delegate
    fileprivate weak var delegate: DataSyncDelegate?
    
    //Peer
    let peer: PeerDevice
    
    fileprivate var nearbyPeers: [PeerDevice]
    
    fileprivate let session: MCSession
    
    fileprivate var needsPairing: Bool = false
    
    //Invitations
    fileprivate var invitationHandlers: Dictionary<String, (Bool, MCSession?) -> Void> = Dictionary()
    
    public var service: String = ""
    
    private override init() {
        
//        availablePeers = []
//        connectedPeers = []
        nearbyPeers = []
        peer = PeerDevice()
        session = MCSession(peer: peer.deviceID, securityIdentity: nil, encryptionPreference: .required)
        super.init()
        session.delegate = self
    }
    
    deinit {
        disconnect()
    }
    
    public var isConnected: Bool {
        get {
            return nearbyPeers.filter({ (peer: PeerDevice) -> Bool in
                peer.state == .connected
            }).count > 0
        }
    }
    //MARK: Setup Peer Connectivity
    public func setup(withDelegate: DataSyncDelegate, needsPairing: Bool = false, withCompletionHandler: @escaping(Bool) -> ()) {
        guard service != "" else {
            withCompletionHandler(false)
            return
        }
        
        //Service Advertiser
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peer.deviceID, discoveryInfo: nil, serviceType: service)
            
        serviceAdvertiser?.delegate = self
        
        //Browser
        serviceBrowser = MCNearbyServiceBrowser(peer: peer.deviceID, serviceType: service)
        serviceBrowser?.delegate = self
        
        self.delegate = withDelegate
        self.needsPairing = needsPairing
        withCompletionHandler(true)
        
    }
    
    //MARK: Conneting Both User One after other
    public func connect(forUser: User, fromViewController: UIViewController? = nil) {
        switch forUser {
            case .Host:
                scanning(fromViewController: fromViewController)
            
            case .Peer:
                start()
        }
        
    }
    
    //MARK: Auto Connect for Both Users Simultaneously
    public func autoConnect(fromViewController: UIViewController? = nil) {
        connect(forUser: .Host, fromViewController: fromViewController)
        connect(forUser: .Peer, fromViewController: fromViewController)
    }
    
    public func disconnect(_ forUser: User? = nil) {
        guard let user = forUser else {
            serviceAdvertiser?.stopAdvertisingPeer()
            serviceBrowser?.stopBrowsingForPeers()
            nearbyPeers.removeAll()
//            connectedPeers.removeAll()
//            availablePeers.removeAll()
            return
        }
        switch user {
            case .Peer:
                start(false)
            default:
            break
            
        }
    }
    
    public func sendInvitationForPairing(toPeer: PeerDevice) {
        guard needsPairing, let peerToPaired = getAvailablePeers().filter({ (peer: PeerDevice) -> Bool in
            toPeer.deviceID.displayName == peer.deviceID.displayName
        }).first else {
            return
        }
        serviceBrowser?.invitePeer(peerToPaired.deviceID, to: session, withContext: nil, timeout: connectionTimeOut)
    }
    
    //MARK: Send Data with Type
    public func send(data: Any, ofType: Type, withID: Any, to: PeerDevice? = nil) {
        
        switch ofType {
            case .Acknowledge:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    guard let devices = data as? [PeerDevice], devices.count > 0 else {
                        print("Unable to Acknowledge")
                        return
                    }
                    do {
                        let container = Container(data: "Acknowledged" , ofType: ofType, forDataID: withID)
                        guard let convertedData = Data.toData(object: container) else {
                            print("Data Not Converted \(data)")
                            return
                        }
                        let peerToAcknowledge = self.session.connectedPeers.filter({ (peer: MCPeerID) -> Bool in
                            return peer.displayName == devices[0].deviceID.displayName
                        })
                        print("Acknowledging Peer Count: \(peerToAcknowledge.count)")
	                        print("Acknowledging Peer: \(peerToAcknowledge[0].displayName)")
                        try self.session.send(convertedData, toPeers: peerToAcknowledge, with: .reliable)
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                })
            
            default:
                if isConnected {
                    do {
                        let container = Container(data: data, ofType: ofType, forDataID: withID)
                        guard let convertedData = Data.toData(object: container) else {
                            print("Data Not Converted \(data)")
                            return
                        }
                        try session.send(convertedData, toPeers: to == nil ? session.connectedPeers : self.session.connectedPeers.filter({ (peer: MCPeerID) -> Bool in
                            return peer.displayName == to?.deviceID.displayName
                        }), with: .reliable)
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
        }
        
    }
    
    //MARK: Peer
    public func getAvailablePeers() -> [PeerDevice] {
        let availablePeers = nearbyPeers.filter { (peer: PeerDevice) -> Bool in
            peer.state == .connecting
        }
        return availablePeers
    }
    
    public func getConnectedPeers() -> [PeerDevice] {
        let connectedPeers = nearbyPeers.filter { (peer: PeerDevice) -> Bool in
            peer.state == .connected
        }
//        let connectedPeers = session.connectedPeers.map {
//            PeerDevice(withID: $0.displayName, state: .connected, udid: nil) }
        return connectedPeers
    }
    
    public func getHistoryDisconnectedPeers() -> [PeerDevice] {
        let historyDevices = Set<PeerDevice>(PeerConnectivity.instance.getAllRegisteredDevices())
        let connectedDevices = Set<PeerDevice>(PeerConnectivity.instance.getConnectedPeers())
        let availableDevices = Set<PeerDevice>(PeerConnectivity.instance.getAvailablePeers())

        return Array((historyDevices.symmetricDifference(connectedDevices)).symmetricDifference(availableDevices))
    }
    
    public func getCurrentDisconnectPeers() -> [PeerDevice] {
        let disconnectedPeers = nearbyPeers.filter { (peer: PeerDevice) -> Bool in
            peer.state == .notConnected
        }
        return disconnectedPeers
    }
    
    //MARK: Realm
    public func getAllRegisteredDevices() -> [PeerDevice] {
        return RealmHelper.instance.getDevicesHistory()
    }
    
    //MARK: Helper Methods
    fileprivate func start(_ isJoin: Bool = true) {
        if isJoin {
            serviceAdvertiser?.startAdvertisingPeer()
        }
        else {
            serviceAdvertiser?.stopAdvertisingPeer()
        }
    }
    
    fileprivate func scanning(fromViewController: UIViewController?) {
        serviceBrowser?.startBrowsingForPeers()
    }
}

//MARK: Session Delegate
extension PeerConnectivity: MCSessionDelegate {
    
    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connected:
                nearbyPeers.filter { $0.deviceID.displayName == peerID.displayName }.first?.state = .connected
                print("Connected \(peerID.displayName).")
            
            case .connecting:
                print("Connecting \(peerID.displayName)..")
                nearbyPeers.filter { $0.deviceID.displayName == peerID.displayName }.first?.state = .connecting
            
            case .notConnected:
                nearbyPeers.filter { $0.deviceID.displayName == peerID.displayName }.first?.state = .notConnected
                self.delegate?.lost(device: PeerDevice(withID: peerID.displayName, state: .notConnected, udid: nil), at: Date())
            
        }
        
        DispatchQueue.main.async {
            self.delegate?.update(devices: self.nearbyPeers, at: Date())
        }
    }
    
    //Received data, update delegate didRecieveData
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data: \(data.count) bytes from \(peerID.displayName)")
        
        guard let container = data.convert() else { return }
        
        DispatchQueue.main.async {
            switch container.type {
                case .Acknowledge:
                    DispatchQueue.main.async {
                        print("Acknowledgment from: \(peerID.displayName) for data: \(container.id)")
                        self.delegate?.acknowledge(from: PeerDevice(withID: peerID.displayName, state: .connected, udid: nil), at: Date(), forDataID: container.id)
                    }
                
                default:
                    self.delegate?.sync(dataDidReceive: container.data, ofType: container.type, at: Date(), fromPeer: PeerDevice(displayName: peerID.displayName, uuid: nil))
                    PeerConnectivity.instance.send(data: [PeerDevice(withID: peerID.displayName, state: .connected, udid: nil)], ofType: .Acknowledge, withID: container.id)
            }
        }
    }
    
    //Received Stream
    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Received stream")
    }
    
    /// Started receiving resource
    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Started receiving resource with name: \(resourceName)")
    }
    
    /// Finished receiving resource
    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Finished receiving resource with name: \(resourceName)")
    }
    
    private func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
}

extension PeerConnectivity: MCNearbyServiceAdvertiserDelegate {
    
    // Received invitation
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("Invitation Received \(peerID.displayName)")
        
        OperationQueue.main.addOperation {
            invitationHandler(true, self.session)
        }
    }
    
    //Error, could not start advertising
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Could not start advertising due to error: \(error)")
    }
    
}

//MARK: Browser Delegate
extension PeerConnectivity: MCNearbyServiceBrowserDelegate {
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("Found peer: \(peerID)")
        let foundPeer = PeerDevice(withPeer: peerID, state: .connecting, udid: nil)
        let isPeerInList = nearbyPeers.contains(where: { (peer: PeerDevice) -> Bool in
            peer.deviceID.displayName == peerID.displayName
        })
        if !isPeerInList {
            nearbyPeers.append(foundPeer)
        }
        nearbyPeers.filter { $0.deviceID.displayName == peerID.displayName }.first?.state = .connecting
        
        if !needsPairing {
            browser.invitePeer(peerID, to: session, withContext: nil, timeout: connectionTimeOut)
        }
        self.delegate?.update(devices: self.nearbyPeers, at: Date())
        
        guard !(RealmHelper.instance.getDevicesHistory().contains { $0.deviceID.displayName == foundPeer.deviceID.displayName }) else {
            return
        }
        RealmHelper.instance.store(device: foundPeer)
    }
    
    //Lost a peer, update the list of available peers
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID.displayName)")
        
        // Update the lost peer
        nearbyPeers.filter { $0.deviceID.displayName == peerID.displayName }.first?.state = .notConnected
        DispatchQueue.main.async {
            self.delegate?.update(devices: self.nearbyPeers, at: Date())
            self.delegate?.lost(device: PeerDevice(withID: peerID.displayName, state: .notConnected, udid: nil), at: Date())
        }
    }
    
    //Error, could not start browsing
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Could not start browsing due to error: \(error)")
    }
    
}
