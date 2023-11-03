//
//  LeaseBuyViewController.swift
//  BevoPlace
//
//  Created by Shaz Momin on 10/12/23.
//

import UIKit
import FirebaseAuth

public var items = [
    Product(id: 1, name: "Vintage Texas Sweatshirt", description: "Lightly worn sweatshirt, burnt orange gameday fit", userID: 1, image: "https://www.google.com", lease: true, price: 25,
            period: Period.week ,numPeriods: 3, size: Size.L)
]

class LeaseBuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemTableView: UITableView!

    
    
    let itemCellIdentifier = "ItemCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        cell.productTitleLabel.text = items[row].name
        cell.productSizeLabel.text = "Size: \(String(describing: items[row].size))"
        if (!items[row].lease) {
            // Buy Item interface
            cell.productPriceLabel.text = "Price: $\(String(round(items[row].price)))"
            cell.leaseLengthLabel.text = ""
        } else {
            // Lease Item interface
            cell.productPriceLabel.text = "Price: $\(String(round(items[row].price)))/\(String(describing: items[row].period))"
            cell.leaseLengthLabel.text = "Lease length: \(items[row].numPeriods) \(String(describing: items[row].period))s"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue",
           let destination = segue.destination as? AddItemViewController
        {
            //destination.delegate = self
        }
    }
//=======
//>>>>>>> c082c2585ae19a9c9ded1c4c3b31f23751fdc03e

}
