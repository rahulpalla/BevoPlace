//
//  LeaseBuyViewController.swift
//  BevoPlace
//
//  Created by Shaz Momin on 10/12/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage




public var items = [Product]()

class LeaseBuyViewController: UIViewController, ObservableObject, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var itemTableView: UITableView!

    let itemCellIdentifier = "ItemCell"
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
    
        myRefreshControl.addTarget(self, action: #selector( handleRefreshControl(_:)), for: .valueChanged)
        self.itemTableView.addSubview(self.myRefreshControl)
        
        self.fetchAllProducts()
        self.itemTableView.reloadData()
        // Important setup for Table View.
        itemTableView.delegate = self
        itemTableView.dataSource = self
        
        itemTableView.layer.cornerRadius = 10.0
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back2.jpeg")!)
        
    }
    
    @objc func handleRefreshControl(_ myRefreshControl: UIRefreshControl) {
       // Update your content…
        self.fetchAllProducts()
        self.itemTableView.reloadData()
       // Dismiss the refresh control.
       DispatchQueue.main.async {
          myRefreshControl.endRefreshing()
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath as IndexPath) as! ProductCell
        
        let row = indexPath.row
        
        // download image from firebase with the url
        let pathReference = Storage.storage().reference(withPath: "image/\(items[row].docID)/productPhoto")
        pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
            } else {
                cell.ProductImage.image = UIImage(data: data!)
            }
        }
        
        cell.leaseBuyLabel.layer.cornerRadius = 10
        cell.leaseBuyLabel.layer.masksToBounds = true
        cell.productTitleLabel?.text = items[row].name
        cell.productSizeLabel.text = "\(String(describing: items[row].category))"
        
        let price = round(items[row].price * 100.0) / 100.0
        if (!items[row].lease) {
            // Buy Item interface
            cell.productPriceLabel.text = "$\(String(price))"
            cell.leaseLengthLabel.text = ""
            cell.dummyLeaseLengthLabel.isHidden = true
            cell.leaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.dummyLeaseLengthLabel.isHidden = false
            cell.productPriceLabel.text = "$\(String(price))/\(items[row].period)"
            cell.leaseLengthLabel.text = "\(items[row].numPeriods) \(items[row].period)s"
            cell.leaseBuyLabel.text = "Lease"
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
                    self.itemTableView.reloadData()
                }
            }
        }
    }

}
