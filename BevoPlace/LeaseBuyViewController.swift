//
//  LeaseBuyViewController.swift
//  BevoPlace
//
//  Created by Shaz Momin on 10/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore




public var items = [Product]()

class LeaseBuyViewController: UIViewController, ObservableObject, UITableViewDelegate, UITableViewDataSource {
    
    var itmes:[Product] = []
    
    @IBOutlet weak var itemTableView: UITableView!

    let itemCellIdentifier = "ItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchAllProducts()
        // Important setup for Table View.
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath as IndexPath) as! ProductCell
        
        let row = indexPath.row
        cell.productTitleLabel?.text = items[row].name
        cell.productSizeLabel.text = "Size: \(String(describing: items[row].size))"
        
        let price = round(items[row].price * 100.0) / 100.0
        if (!items[row].lease) {
            // Buy Item interface
            cell.productPriceLabel.text = "Price: $\(String(price))"
            cell.leaseLengthLabel.text = ""
        } else {
            // Lease Item interface
            cell.productPriceLabel.text = "Price: $\(String(price))/\(items[row].period)"
            cell.leaseLengthLabel.text = "Lease length: \(items[row].numPeriods) \(items[row].period)s"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "leaseBuyToViewItemSegue",
            let viewItemVC = segue.destination as? ViewItemViewController,
            let index = itemTableView.indexPathForSelectedRow?.row {
            viewItemVC.delegate = self
            viewItemVC.index = index
            viewItemVC.product = items[index]
        }
    }
    
    func fetchAllProducts() {
        db.collection("products").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    var data = document.data()
                    //print("\(document.documentID): \(document.data())")
                    let price = data["price"] as? Double ?? 0.0
                    let lease = data["lease"] as? Bool ?? true
                    let period = data["period"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let size = data["size"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = data["id"] as? Int ?? 0
                    let image = data["image"] as? String ?? ""
                    let numPeriods = data["numPeriods"] as? Int ?? 0
                    let description = data["description"] as? String ?? ""
                    items.append(Product(id: id, name: name, description: description, userID: userID, image: image, lease: lease, price: price, period: period, numPeriods: numPeriods, size: size))
                    self.itemTableView.reloadData()
                }
            }
        }
    }
    

}
