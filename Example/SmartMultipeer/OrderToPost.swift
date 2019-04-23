//
//  Order.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/15/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

class OrderToPost: NSObject, Codable, NSSecureCoding {
    
    static var supportsSecureCoding: Bool = true
    
    var orderID: Int64
    let authenticatedCode, offlineUniqueID: String
    let orderNo, transactionNo: Int64
    let orderReferenceID: String?

    var orderItems: [OrderItem]

    
    enum CodingKeys: String, CodingKey {
        case orderID = "OrderID"
        case authenticatedCode = "AuthenticatedCode"
        case offlineUniqueID = "OfflineUniqueID"
        case orderNo = "OrderNo"
        case transactionNo = "TransactionNo"
        case orderReferenceID = "OrderReferenceId"
        case orderItems = "OrderItems"
    }
    
    init(orderID: Int64, authenticatedCode: String, offlineUniqueID: String, orderNo: Int64, transactionNo: Int64, orderReferenceID: String?, orderItems: [OrderItem]) {
        self.orderID = orderID
        self.authenticatedCode = authenticatedCode
        self.offlineUniqueID = offlineUniqueID
        self.orderNo = orderNo
        self.transactionNo = transactionNo
        self.orderReferenceID = orderReferenceID
        self.orderItems = orderItems
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(orderID, forKey: OrderToPost.CodingKeys.orderID.rawValue)

        aCoder.encode(authenticatedCode, forKey: OrderToPost.CodingKeys.authenticatedCode.rawValue)

        aCoder.encode(offlineUniqueID, forKey: OrderToPost.CodingKeys.offlineUniqueID.rawValue)

        aCoder.encode(orderNo, forKey: OrderToPost.CodingKeys.orderNo.rawValue)

        aCoder.encode(transactionNo, forKey: OrderToPost.CodingKeys.transactionNo.rawValue)

        aCoder.encode(orderReferenceID, forKey: OrderToPost.CodingKeys.orderReferenceID.rawValue)

        aCoder.encode(orderItems, forKey: OrderToPost.CodingKeys.orderItems.rawValue)
    }

    required init?(coder aDecoder: NSCoder) {
        self.orderID = aDecoder.decodeInt64(forKey: OrderToPost.CodingKeys.orderID.rawValue)
        self.authenticatedCode = aDecoder.decodeObject(forKey: OrderToPost.CodingKeys.authenticatedCode.rawValue) as? String ?? "65"
        self.transactionNo = aDecoder.decodeInt64(forKey: OrderToPost.CodingKeys.transactionNo.rawValue)
        self.offlineUniqueID = aDecoder.decodeObject(forKey: OrderToPost.CodingKeys.offlineUniqueID.rawValue) as? String ?? "45"
        self.orderNo = aDecoder.decodeInt64(forKey: OrderToPost.CodingKeys.orderNo.rawValue)
        self.orderReferenceID = aDecoder.decodeObject(forKey: OrderToPost.CodingKeys.orderReferenceID.rawValue) as? String
        self.orderItems = aDecoder.decodeObject(forKey: OrderToPost.CodingKeys.orderItems.rawValue) as! [OrderItem]
    }
}

class OrderItem: NSObject, Codable, NSSecureCoding {
    static var supportsSecureCoding: Bool  = true
    
    let orderDetailID, itemID: Int64
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case orderDetailID = "OrderDetailId"
        case itemID = "ItemId"
        case name = "Name"
    }
    
    init(name: String, itemId: Int64, orderDetailID: Int64) {
        self.name = name
        self.itemID = itemId
        self.orderDetailID = orderDetailID
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: OrderItem.CodingKeys.name.rawValue)

        aCoder.encode(orderDetailID, forKey: OrderItem.CodingKeys.orderDetailID.rawValue)

        aCoder.encode(itemID, forKey: OrderItem.CodingKeys.itemID.rawValue)

    }

    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: OrderItem.CodingKeys.name.rawValue) as? String ?? "BBQ"
        self.itemID = aDecoder.decodeInt64(forKey: OrderItem.CodingKeys.itemID.rawValue)
        self.orderDetailID = aDecoder.decodeInt64(forKey: OrderItem.CodingKeys.orderDetailID.rawValue)
    }
}
