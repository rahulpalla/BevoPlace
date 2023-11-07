//
//  LendSellViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/6/23.
//

import UIKit

class LendSellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var myItems:[Product] = []
    
    
    @IBOutlet weak var myItemTableView: UITableView!
    
    let itemCellIdentifier = "MyItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fetchAllProducts()
        // Important setup for Table View.
        myItemTableView.delegate = self
        myItemTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyItemCell", for: indexPath) as! MyProductCell
        
        let row = indexPath.row
//        cell.productTitleLabel?.text = myItems[row].name
        cell.productSizeLabel.text = "Size: \(String(describing: myItems[row].size))"
//        if (!myItems[row].lease) {
//            // Buy Item interface
//            cell.productPriceLabel.text = "Price: $\(String(round(myItems[row].price)))"
//            cell.leaseLengthLabel.text = ""
//        } else {
//            // Lease Item interface
//            cell.productPriceLabel.text = "Price: $\(String(round(myItems[row].price)))/\(myItems[row].period))"
//            cell.leaseLengthLabel.text = "Lease length: \(myItems[row].numPeriods) \(myItems[row].period))s"
//        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue",
           let destination = segue.destination as? AddItemViewController
        {
            //destination.delegate = self
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
                    self.myItems.append(Product(id: id, name: name, description: description, userID: userID, image: image, lease: lease, price: price, period: period, numPeriods: numPeriods, size: size))
                    self.myItemTableView.reloadData()
                    print("MY ITEMSSS: \(self.myItems)")
                }
            }
        }
    }

}
