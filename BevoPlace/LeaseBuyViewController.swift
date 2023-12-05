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

class LeaseBuyViewController: UIViewController, ObservableObject, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var filteredItems : [Product] = items
    let itemCellIdentifier = "ItemCell"
    let myRefreshControl = UIRefreshControl()
        
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!


    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        myRefreshControl.addTarget(self, action: #selector( handleRefreshControl(_:)), for: .valueChanged)
        self.itemTableView.addSubview(self.myRefreshControl)
        self.fetchAllProducts()
        self.itemTableView.reloadData()
        
        // Important setup for Table View.
        itemTableView.delegate = self
        itemTableView.dataSource = self
        filteredItems = items
        
        itemTableView.layer.cornerRadius = 10.0
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
        self.itemTableView.reloadData()
        // Dismiss the refresh control.
       DispatchQueue.main.async {
          myRefreshControl.endRefreshing()
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        itemTableView.reloadData()
        updateBackground()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath as IndexPath) as! ProductCell
        let row = indexPath.row
        
        cell.ProductImage.image = filteredItems[row].image
        cell.leaseBuyLabel.layer.cornerRadius = 10
        cell.leaseBuyLabel.layer.masksToBounds = true
        cell.productTitleLabel?.text = filteredItems[row].name
        cell.productSizeLabel.text = "\(String(describing: filteredItems[row].category))"
        cell.textLabel?.backgroundColor = UIColor.red
        
        let price = round(filteredItems[row].price * 100.0) / 100.0
        if (!filteredItems[row].lease) {
            // Buy Item interface
            cell.productPriceLabel.text = "$\(String(price))"
            cell.leaseLengthLabel.text = ""
            cell.dummyLeaseLengthLabel.isHidden = true
            cell.leaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.dummyLeaseLengthLabel.isHidden = false
            cell.productPriceLabel.text = "$\(String(price))/\(filteredItems[row].period)"
            cell.leaseLengthLabel.text = "\(filteredItems[row].numPeriods) \(filteredItems[row].period)s"
            cell.leaseBuyLabel.text = "Lease"
        }
        
        // Only masking the leading and trailing corners of cells in the tableview
        if (row == 0 && filteredItems.count == 1) {
            cell.layer.cornerRadius = 15
        } else if (row == 0) {
            cell.layer.cornerRadius = 15
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if (row == filteredItems.count - 1) {
            cell.layer.cornerRadius = 15
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
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
                    items.append(product)

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
                    self.filteredItems = items
                    // Reload the table view with the updated data
                    self.itemTableView.reloadData()
                }
            }
        }
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            filteredItems = items
        } else {
            filteredItems = []
            for item in items{
                if item.name.lowercased().contains(searchText.lowercased()){
                    filteredItems.append(item)
                }
            }
        }
        self.itemTableView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
