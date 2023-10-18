//
//  LeaseBuyViewController.swift
//  BevoPlace
//
//  Created by Shaz Momin on 10/12/23.
//

import UIKit
import FirebaseAuth

// Types of period (for lease length)
enum Period {
    case none, day, week, month
}

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

public var items = [
    Product(id: 1, name: "Vintage Texas Sweatshirt", description: "Lightly worn sweatshirt, burnt orange gameday fit", userID: 1, image: "https://www.google.com", lease: true, price: 5, numPeriods: 3, size: Size.L)
]

class LeaseBuyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemTableView: UITableView!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    
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
        let cell = itemTableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath as IndexPath)

        let row = indexPath.row
        cell.textLabel?.text = items[row].name
        cell.detailTextLabel?.text = items[row].description
        
        return cell
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }
}
