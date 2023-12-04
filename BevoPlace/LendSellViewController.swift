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
        myFilteredItems = myItems
        
        updateBackground()

        UserSettingsManager.shared.onChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateBackground()
            }
        }
        
    }
    
    func updateBackground() {
        let backgroundImageName = UserSettingsManager.shared.darkModeEnabled ? "dark.jpeg" : "back2.jpeg"
        let backgroundImage = UIImage(named: backgroundImageName)
        
        // Set the content mode to aspect fill
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = view.bounds
        
        // Remove existing background image views
        view.subviews.filter { $0 is UIImageView }.forEach { $0.removeFromSuperview() }

        // Add the new background image view
        view.insertSubview(imageView, at: 0)
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
                
//        let imgPath = "image/\(myItems[row].docID)/productPhoto"
//        
//        // download image from firebase with the url
//        let pathReference = Storage.storage().reference(withPath: imgPath)
//        pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
//            if let error = error {
//                // Uh-oh, an error occurred!
//                print(error.localizedDescription)
//                cell.myProductImage.image = UIImage()
//            } else {
//                cell.myProductImage.image = UIImage(data: data!)
//            }
//        }
        
        cell.myProductImage.image = myFilteredItems[row].image
        
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
        
        // Only masking the leading and trailing corners of cells in the tableview
        if (row == 0) {
            cell.layer.cornerRadius = 15
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if (row == myFilteredItems.count - 1) {
            cell.layer.cornerRadius = 15
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addItemSegue",
           let destination = segue.destination as? AddItemViewController
        {
            
        } else if segue.identifier == "lendSellToViewItemSegue",
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
            db.collection("products").document(myFilteredItems[indexPath.row].docID).delete()
            
            // delete from current items
            for i in 0...items.count {
                if (items[i].docID == myFilteredItems[indexPath.row].docID) {
                    items.remove(at: i)
                    break
                }
            }
            let temp: Product = myFilteredItems[indexPath.row]
            myFilteredItems.remove(at: indexPath.row)
            for i in 0...myItems.count{
                if (temp.docID == myItems[i].docID){
                    myItems.remove(at: i)
                    break
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func fetchAllProducts() {
        myItems.removeAll()

        db.collection("products").getDocuments() { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                // Create a DispatchGroup to track the completion of all asynchronous tasks
                let dispatchGroup = DispatchGroup()

                for document in querySnapshot!.documents {
                    // Enter the DispatchGroup before starting each asynchronous task
                    dispatchGroup.enter()

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

                    // Create a product with a placeholder UIImage
                    let product = Product(id: id, name: name, description: description, category: category, userID: userID, image: image, lease: lease, price: price, period: period, numPeriods: numPeriods, size: size, docID: docID)

                    // Append the product to the items array
                    if(product.userID == user){
                        self.myItems.append(product)
                    }

                    let imgPath = "image/\(docID)/productPhoto"
                    let pathReference = Storage.storage().reference(withPath: imgPath)

                    // Download image data asynchronously
                    pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                        // Ensure the leave() call is executed even if there's an error
                        defer {
                            dispatchGroup.leave()
                        }

                        if let error = error {
                            // Uh-oh, an error occurred!
                            print(error.localizedDescription)
                        } else {
                            // Set the product's image property once the image data is retrieved
                            product.image = UIImage(data: data!)!
                        }
                    }
                }

                // Notify the main queue when all asynchronous tasks are complete
                dispatchGroup.notify(queue: .main) {
                    // Update the filteredItems array with the downloaded data
                    self.myFilteredItems = self.myItems
                    // Reload the table view with the updated data
                    self.myItemTableView.reloadData()
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
