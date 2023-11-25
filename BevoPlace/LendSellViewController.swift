//
//  LendSellViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/6/23.
//

import UIKit
import FirebaseStorage

class LendSellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var myItems:[Product] = []
    
    var myFilteredItems : [Product] = items
    
    @IBOutlet weak var myItemTableView: UITableView!
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let itemCellIdentifier = "MyItemCell"
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        myRefreshControl.addTarget(self, action: #selector( handleRefreshControl(_:)), for: .valueChanged)
        self.myItemTableView.addSubview(self.myRefreshControl)
        
        self.fetchAllProducts()
        // Important setup for Table View.
        myItemTableView.delegate = self
        myItemTableView.dataSource = self
        myItemTableView.layer.cornerRadius = 10.0
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "back2.jpeg")!)
        myFilteredItems = myItems
        
    }
    
    @objc func handleRefreshControl(_ myRefreshControl: UIRefreshControl) {
       // Update your content…
        self.fetchAllProducts()
        self.myItemTableView.reloadData()
       // Dismiss the refresh control.
       DispatchQueue.main.async {
          myRefreshControl.endRefreshing()
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myItemTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myFilteredItems.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyItemCell", for: indexPath) as! MyProductCell
        
        let row = indexPath.row
        
        // download image from firebase with the url
        let pathReference = Storage.storage().reference(withPath: "image/\(myFilteredItems[row].docID)/productPhoto")
        pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
            if let error = error {
                // Uh-oh, an error occurred!
                print(error.localizedDescription)
                cell.myProductImage.image = UIImage()
            } else {
                cell.myProductImage.image = UIImage(data: data!)
            }
        }
        
        cell.leaseBuyLabel.layer.cornerRadius = 10
        cell.leaseBuyLabel.layer.masksToBounds = true
        cell.productTitleLabel?.text = myFilteredItems[row].name
        cell.productSizeLabel.text = "\(String(describing: myFilteredItems[row].category))"

        
        let price = round(myFilteredItems[row].price * 100.0) / 100.0
        if (!myFilteredItems[row].lease) {
            // Buy Item interface
            cell.dummyLeaseLengthLabel.isHidden = true
            cell.productPriceLabel.text = "$\(String(price))"
            cell.leaseLengthLabel.text = ""
            cell.leaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.dummyLeaseLengthLabel.isHidden = false
            cell.productPriceLabel.text = "$\(String(price))/\(myFilteredItems[row].period)"
            cell.leaseLengthLabel.text = "\(myFilteredItems[row].numPeriods) \(myFilteredItems[row].period)s"
            cell.leaseBuyLabel.text = "Lease"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue",
           let destination = segue.destination as? AddItemViewController
        {
        }
        
        
        else if segue.identifier == "lendSellToViewItemSegue",
                let viewItemVC = segue.destination as? ViewItemViewController,
                let index = myItemTableView.indexPathForSelectedRow?.row {
                viewItemVC.delegate = self
                viewItemVC.index = index
                viewItemVC.product = myItems[index]
            }
    }
    
    // Swiping to delete the item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete from firestore
            db.collection("products").document(myItems[indexPath.row].docID).delete()
            
            // delete from current items
            for i in 0...items.count {
                if (items[i].docID == myItems[indexPath.row].docID) {
                    items.remove(at: i)
                    break
                }
            }
            myItems.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.myFilteredItems = self.myItems
        }
    }
    
    func fetchAllProducts() {
        self.myItems.removeAll()
        db.collection("products").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    var data = document.data()
                    let price = data["price"] as? Double ?? 0.0
                    let category = data["category"] as? String ?? ""
                    let lease = data["lease"] as? Bool ?? true
                    let period = data["period"] as? String ?? ""
                    let userID = data["userID"] as? String ?? ""
                    let size = data["size"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = data["id"] as? Int ?? 0
                    let image = data["image"] as? String ?? ""
                    let numPeriods = data["numPeriods"] as? Int ?? 0
                    let description = data["description"] as? String ?? ""
                    let docID = data["docID"] as? String ?? ""
                    
                    var newProd = Product(id: id, name: name, description: description, category: category, userID: userID, image: image, lease: lease, price: price, period: period, numPeriods: numPeriods, size: size, docID: docID)
                    
                    if (userID == user) {
                        self.myItems.append(newProd)
                    }
                    self.myFilteredItems = self.myItems
                    self.myItemTableView.reloadData()
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            myFilteredItems = myItems
        }
        else{
            myFilteredItems = []
            for myItem in myItems{
                if myItem.name.lowercased().contains(searchText.lowercased()){
                    myFilteredItems.append(myItem)
                }
            }
        }
        self.myItemTableView.reloadData()
    }

}
