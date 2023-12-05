//
//  Product.swift
//  BevoPlace
//
//  Created by Shaz Momin on 11/1/23.
//

import Foundation
import UIKit

//Product class
public class Product {
    //Product class variables
    var id: Int
    var name: String
    var description: String
    var category: String
    var lease: Bool
    var price: Double
    var period: String
    var numPeriods: Int
    var size: String
    var userID: String
    var imagePath: String
    var image: UIImage
    var docID: String
    
    //initializing product
    init(id: Int, name: String, description: String, category: String, userID: String, image: String, lease: Bool, price: Double, period: String, numPeriods: Int, size: String, docID: String) {
        self.id = id
        self.name = name
        self.description = description
        self.category = category
        self.lease = lease
        self.price = price
        self.period = period
        self.numPeriods = numPeriods
        self.size = size
        self.userID = userID
        self.imagePath = image
        self.image = UIImage()
        self.docID = docID
    }
    
}
