//
//  WishlistViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/27/23.
//

import UIKit

class WishlistViewController: UIViewController {
    
    @IBOutlet weak var wishlistTableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fetchAllProducts()
        self.itemTableView.reloadData()
        // Important setup for Table View.
        itemTableView.delegate = self
        itemTableView.dataSource = self
    }
    
    func fetchAllProducts() {
        items.removeAll()
        db.collection("products").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    var data = document.data()
                    let price = data["price"] as? Double ?? 0.0
                    let lease = data["lease"] as? Bool ?? true
                    let category = data["category"] as? String ?? ""
                    let period = data["period"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let size = data["size"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = data["id"] as? Int ?? 0
                    let image = data["image"] as? String ?? ""
                    let numPeriods = data["numPeriods"] as? Int ?? 0
                    let description = data["description"] as? String ?? ""
                    let docID = data["docID"] as? String ?? ""
                    items.append(Product(id: id, name: name, description: description, category: category, userID: userID, image: image, lease: lease, price: price, period: period, numPeriods: numPeriods, size: size, docID: docID))
                    //self.filteredItems = items
                    self.itemTableView.reloadData()
                }
            }
        }


}
