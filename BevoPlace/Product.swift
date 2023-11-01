//
//  Product.swift
//  BevoPlace
//
//  Created by Shaz Momin on 11/1/23.
//

import Foundation

// Types of period (for lease length)
enum Period {
    case none, day, week, month
}

// Clothing sizes (varieties)
enum Size {
    case none, XS, S, M, L, XL, XXL
}

public class Product {
    var id: Int
    var name: String
    var description: String
    var lease: Bool
    var price: Double
    var period: Period
    var numPeriods: Int
    var size: Size
    var userID: Int
    var image: String
    
    init(id: Int, name: String, description: String, userID: Int, image: String, lease: Bool, price: Double, period: Period = Period.none, numPeriods: Int = 0, size: Size = Size.none) {
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
