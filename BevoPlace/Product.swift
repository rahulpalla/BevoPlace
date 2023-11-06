//
//  Product.swift
//  BevoPlace
//
//  Created by Shaz Momin on 11/1/23.
//

import Foundation

public class Product {
    var id: Int
    var name: String
    var description: String
    var lease: Bool
    var price: Double
    var period: String
    var numPeriods: Int
    var size: String
    var userID: Int
    var image: String
    
    init(id: Int, name: String, description: String, userID: Int, image: String, lease: Bool, price: Double, period: String, numPeriods: Int, size: String) {
        self.id = id
        self.name = name
        self.description = description
        self.lease = lease
        self.price = price
        self.period = period
        self.numPeriods = numPeriods
        self.size = size
        self.userID = userID
        self.image = image
    }
    
}