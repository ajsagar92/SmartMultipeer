# SmartMultipeer

[![CI Status](https://img.shields.io/travis/ajsagar92/SmartMultipeer.svg?style=flat)](https://travis-ci.org/ajsagar92/SmartMultipeer)
[![Version](https://img.shields.io/cocoapods/v/SmartMultipeer.svg?style=flat)](https://cocoapods.org/pods/SmartMultipeer)
[![License](https://img.shields.io/cocoapods/l/SmartMultipeer.svg?style=flat)](https://cocoapods.org/pods/SmartMultipeer)
[![Platform](https://img.shields.io/cocoapods/p/SmartMultipeer.svg?style=flat)](https://cocoapods.org/pods/SmartMultipeer)

## Example

To run the example project, clone the repo, and run from the Example directory first.

## Requirements
iOS Version required is 11.0

## Installation

SmartMultipeer is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SmartMultipeer'
```

## Usage
1. Import the module
```swift
import SmartMultipeer
```

### Classes & Protocol
You need to use `PeerConnectivity.swift` file that manages everything and contains all required methods. `DataSync.swfit` protocol contains DataSyncDelegate that needs to be implemented in class to receive data. It contains 4 methods that are:

```swift
    func sync(dataDidReceive: Any, ofType: Type, at: Date)
```
Method is called when data is received on other device

```swift
    func update(devices: [PeerDevice], at: Date)
```
Method is called when any device is added / lost

```swift
    func lost(device: PeerDevice, at: Date)
```
Method is called when any device is lost. This method is optional

```swift
    func acknowledge(from: PeerDevice, at: Date, forDataID: Any)
```
Method is called when data is received and sender will be acknowledged. This method is optional

### How to start

1. Initialize service type by using:
```swift
PeerConnectivity.instance.service = "sample-service"
```

2. Setup Multipeer Connectivity
```swift
PeerConnectivity.instance.setup(fromViewController: self, withDelegate: self)
```

3. Connect Users

  a. Individually
```swift
PeerConnectivity.instance.connect(forUser: .Peer)
```
```swift  
PeerConnectivity.instance.connect(forUser: .Host)
```
b. Simultaneously
```swift
PeerConnectivity.instance.autoConnect()
```

4. To send data to connected peers
```swift
func send(data: Any, ofType: Type, withID: Any)
```
You can send data of any type whether its primitive or custom model that is designed or encapsulated in class and 'ofType' that can contain values defined in `Type.swift` enum. 'withID' can be used to validated at the time of acknowledgement.

### Other helper methods & properties
```swift
PeerConnectivity.instance.disconnect()
```
Disconnect all peers and will stop advertising and browsing

```swift
PeerConnectivity.instance.getAllRegisteredDevices()
```
Returns the history of devices connected up till now

```swift
PeerConnectivity.instance.peer
```
Returns the information of current device

```swift
PeerConnectivity.instance.getAvailablePeers()
```
Return all available peers ready to get connected

```swift
PeerConnectivity.instance.getConnectedPeers()
```
Returns all connected peers


## Author

AJ Sagar Parwani
Email: ajay.sagar92@gmail.com

## License

SmartMultipeer is available under the Author's license. See the LICENSE file for more info.
