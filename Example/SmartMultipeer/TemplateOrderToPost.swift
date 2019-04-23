//
//  TemplateOrderToPost.swift
//  MultipeerConnectivityExample
//
//  Created by Ajay Sagar Parwani on 4/15/19.
//  Copyright © 2019 Ajay Sagar Parwani. All rights reserved.
//

import Foundation

struct TemplateOrderToPost {
    
    static let decoder = JSONDecoder()
    
    static func getOrder(orderID: Int64) -> OrderToPost? {
        if let path = Bundle.main.path(forResource: "order", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let orderToPost = try decoder.decode(OrderToPost.self, from: data)
                orderToPost.orderID = orderID
//                orderToPost.orderItems = {OrderItem(name: "BBQ", itemId: 23, orderDetailID: 32)
                return orderToPost
            } catch let error {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
}
