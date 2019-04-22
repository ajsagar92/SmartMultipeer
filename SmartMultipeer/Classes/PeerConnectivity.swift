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

class PeerConnectivity: NSObject, PeerNearByConnectivity {
    
    static let instance = PeerConnectivity()
    
    var connectionTimeOut = 10.0
    
    //Advertising with No Invitation
    private var serviceAdvertiser: MCNearbyServiceAdvertiser?
    
    //Advertising with Invitation
    private var invitationServiceAdvertiser: MCAdvertiserAssistant?
    
    //Browsing Peers
    private var serviceBrowser: MCNearbyServiceBrowser?
    
    //Listing Peers for Browsing
    private var listServiceBrowserController: MCBrowserViewController?
    private weak var browsingControllerDelegate: MCBrowserViewControllerDelegate?
    
    //Send / Receive Data Delegate
    weak var delegate: DataSyncDelegate?
    
    //Peer
    final let peer: PeerDevice
    var availablePeers: [PeerDevice]
    var connectedPeers: [PeerDevice]
    
    private lazy var session: MCSession = {
        let session = MCSession(peer: peer.deviceID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    var service: String = ""
    
    private override init() {
        peer = PeerDevice()
        availablePeers = []
        connectedPeers = []
    }
    
    deinit {
        disconnect()
    }
    
    var isConnected: Bool {
        return connectedPeers.count > 0
    }
    //MARK: Setup Peer Connectivity
    func setup(withInvitation: Bool = false, toListPeers: Bool = false, fromViewController: UIViewController, withDelegate: DataSyncDelegate) {
        guard service != "" else {
            let alertController = UIAlertController(title: "Setup Issue", message: "Error: Service Type", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            fromViewController.present(alertController, animated: true, completion: nil)
            return
        }
        if withInvitation {
            invitationServiceAdvertiser = MCAdvertiserAssistant(serviceType: service, discoveryInfo: nil, session: session)
            invitationServiceAdvertiser?.delegate = self
        }
        else {
            //Service Advertiser
            serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peer.deviceID, discoveryInfo: nil, serviceType: service)
            
            serviceAdvertiser?.delegate = self
        }
        
        //Browser
        if toListPeers {
            listServiceBrowserController = MCBrowserViewController(serviceType: service, session: session)
            listServiceBrowserController?.delegate = browsingControllerDelegate
//            listServiceBrowserController.maximumNumberOfPeers = 30
        }
        else {
            serviceBrowser = MCNearbyServiceBrowser(peer: peer.deviceID, serviceType: service)
            serviceBrowser?.delegate = self
        }
        
        self.delegate = withDelegate
        
    }
    
    //MARK: Conneting Both User One after other
    func connect(forUser: User, toListPeers: Bool = false, withSecureInvitation: Bool = false, fromViewController: UIViewController? = nil) {
        switch forUser {
            case .Host:
                scanning(withInvitation: toListPeers, fromViewController: fromViewController)
            
            case .Peer:
                start(secureInviting: withSecureInvitation)
        }
        
    }
    
    //MARK: Auto Connect for Both Users Simultaneously
    func autoConnect(toListPeers: Bool = false, withSecureInvitation: Bool = false, fromViewController: UIViewController? = nil) {
        connect(forUser: .Host, toListPeers: toListPeers, withSecureInvitation: withSecureInvitation, fromViewController: fromViewController)
        connect(forUser: .Peer, toListPeers: toListPeers, withSecureInvitation: withSecureInvitation)
    }
    
    func disconnect() {
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceBrowser?.stopBrowsingForPeers()
        invitationServiceAdvertiser?.stop()
        connectedPeers.removeAll()
        availablePeers.removeAll()
    }
    
    //MARK: Send Data with Type
    func send(data: Any, ofType: Type, withID: Any) {
        
        switch ofType {
            case .Acknowledge:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                guard let devices = data as? [PeerDevice], devices.count > 0 else {
                    return
                }
                do {
                    let container = Container(data: "Acknowledged" , ofType: ofType, forDataID: withID)
                        guard let convertedData = Data.toData(object: container) else {
                        print("Data Not Converted \(data)")
                        return
                    }
                    try self.session.send(convertedData, toPeers: self.session.connectedPeers.filter({ (peer: MCPeerID) -> Bool in
                        return peer.displayName == devices[0].deviceID.displayName
                    }), with: .reliable)
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
                        try session.send(convertedData, toPeers: session.connectedPeers, with: .reliable)
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                }
        }
        
    }
    
    //MARK: Realm
    func getAllRegisteredDevices() -> [PeerDevice] {
        return RealmHelper.instance.getDevicesHistory()
    }
    
    //MARK: Helper Methods
    fileprivate func start(secureInviting: Bool) {
        if secureInviting {
            invitationServiceAdvertiser?.start()
        }
        else {
            serviceAdvertiser?.startAdvertisingPeer()
        }
    }
    
    fileprivate func scanning(withInvitation: Bool, fromViewController: UIViewController?) {
        if withInvitation {
            guard let browserController = listServiceBrowserController else {
                return
            }
            fromViewController?.present(browserController, animated: true, completion: nil)
        }
        else {
            serviceBrowser?.startBrowsingForPeers()
        }
    }
}

//MARK: Session Delegate
extension PeerConnectivity: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
        switch state {
            case .connected:
                availablePeers = availablePeers.filter {
                    $0.deviceID != peerID
                }
            
            case .connecting:
                availablePeers.filter { $0.deviceID == peerID }.first?.state = state
                print("Connecting \(peerID.displayName)..")
            
            
            case .notConnected:
                availablePeers.filter { $0.deviceID == peerID }.first?.state = state
                self.delegate?.lost(device: PeerDevice(withID: peerID.displayName, state: .notConnected, udid: nil), at: Date())
            
        }
        
        // Update all connected peers
        connectedPeers = session.connectedPeers.map {
            PeerDevice(withID: $0.displayName, state: .connected, udid: nil) }
        
        // Send new connection list to delegate
        DispatchQueue.main.async {
            self.delegate?.update(devices: self.connectedPeers, at: Date())
        }
    }
    
    //Received data, update delegate didRecieveData
    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Received data: \(data.count) bytes")
        
        guard let container = data.convert() else { return }
        
        DispatchQueue.main.async {
            switch container.type {
                case .Acknowledge:
                    DispatchQueue.main.async {
                        self.delegate?.acknowledge(from: PeerDevice(withID: peerID.displayName, state: .connected, udid: nil), at: Date(), forDataID: container.id)
                    }
                
                default:
                    self.delegate?.sync(dataDidReceive: container.data, ofType: container.type, at: Date())
                PeerConnectivity.instance.send(data: [PeerDevice(withID: peerID.displayName, state: .connected, udid: nil)], ofType: .Acknowledge, withID: container.id)
//                    PeerConnectivity.instance.send(data: Container(data: [PeerDevice(withID: peerID.displayName, state: .connected, udid: nil)], ofType: .Acknowledge, forDataID: container.id), ofType: .Acknowledge)
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
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
    
}

extension PeerConnectivity: MCNearbyServiceAdvertiserDelegate {
    
    // Received invitation
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        
//        OperationQueue.main.addOperation {
            invitationHandler(true, self.session)
//        }
    }
    
    //Error, could not start advertising
    public func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("Could not start advertising due to error: \(error)")
    }
    
}

//MARK: Advertiser Assistant
extension PeerConnectivity: MCAdvertiserAssistantDelegate {
    
    func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        
    }
    
    func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        
    }
    
}

//MARK: Browser Delegate
extension PeerConnectivity: MCNearbyServiceBrowserDelegate {
    
    public func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        print("Found peer: \(peerID)")
        
        let foundPeer = PeerDevice(withID: peerID.displayName, state: .notConnected, udid: UIDevice.current.identifierForVendor?.uuidString)
        
        availablePeers.append(foundPeer)
        
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: connectionTimeOut)
        
        guard !(RealmHelper.instance.getDevicesHistory().contains { $0.deviceID.displayName == foundPeer.deviceID.displayName }) else {
            return
        }
        RealmHelper.instance.store(device: foundPeer)
    }
    
    //Lost a peer, update the list of available peers
    public func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("Lost peer: \(peerID)")
        
        // Update the lost peer
        availablePeers = availablePeers.filter { $0.deviceID != peerID }
        connectedPeers = connectedPeers.filter { $0.deviceID != peerID }
        DispatchQueue.main.async {
            self.delegate?.update(devices: self.connectedPeers, at: Date())
            self.delegate?.lost(device: PeerDevice(withID: peerID.displayName, state: .notConnected, udid: nil), at: Date())
        }
    }
    
    //Error, could not start browsing
    public func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Could not start browsing due to error: \(error)")
    }
    
}

//MARK: BrowserViewController Delegate
extension PeerConnectivity: MCBrowserViewControllerDelegate {
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        
    }
    
    // Notifies delegate that a peer was found; discoveryInfo can be used to
    // determine whether the peer should be presented to the user, and the
    // delegate should return a YES if the peer should be presented; this method
    // is optional, if not implemented every nearby peer will be presented to
    // the user.
    func browserViewController(_ browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
}
