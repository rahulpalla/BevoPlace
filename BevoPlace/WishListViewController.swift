//
//  WishListViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 12/1/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

public var wishListItems = [Product]()

class WishListViewController: UIViewController, ObservableObject, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var wishListTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //var myFilteredItems : [Product] = wishListItems
    
    let itemCellIdentifier = "WishListItemCell"
       
       let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        myRefreshControl.addTarget(self, action: #selector( handleRefreshControl(_:)), for: .valueChanged)
        self.wishListTableView.addSubview(self.myRefreshControl)
        
        self.fetchWishList()
        // Important setup for Table View.
        wishListTableView.delegate = self
        wishListTableView.dataSource = self
        wishListTableView.layer.cornerRadius = 10.0
        //myFilteredItems = wishListItems
        
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
        self.fetchWishList()
        self.wishListTableView.reloadData()
       // Dismiss the refresh control.
       DispatchQueue.main.async {
          myRefreshControl.endRefreshing()
       }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        wishListTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishListItems.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListItemCell", for: indexPath) as! WishListProductCell
        
        let row = indexPath.row
        
        cell.wishProductImage.image = wishListItems[row].image
        
        cell.wishLeaseBuyLabel.layer.cornerRadius = 10
        cell.wishLeaseBuyLabel.layer.masksToBounds = true
        cell.wishProductTitleLabel?.text = wishListItems[row].name
        cell.wishProductCategoryLabel.text = "\(String(describing: wishListItems[row].category))"

        
        let price = round(wishListItems[row].price * 100.0) / 100.0
        if (!wishListItems[row].lease) {
            // Buy Item interface
            cell.wishDummyLeaseLengthLabel.isHidden = true
            cell.wishProductPriceLabel.text = "$\(String(price))"
            cell.wishLeaseLengthLabel.text = ""
            cell.wishLeaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.wishDummyLeaseLengthLabel.isHidden = false
            cell.wishProductPriceLabel.text = "$\(String(price))/\(wishListItems[row].period)"
            cell.wishLeaseLengthLabel.text = "\(wishListItems[row].numPeriods) \(wishListItems[row].period)s"
            cell.wishLeaseBuyLabel.text = "Lease"
        }
        cell.layer.cornerRadius = 15
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "wishListToViewItem",
                let viewItemVC = segue.destination as? ViewItemViewController,
                  let index = wishListTableView.indexPathForSelectedRow?.row {
            viewItemVC.delegate = self
            viewItemVC.index = index
            viewItemVC.product = wishListItems[index]
        }
    }
    
    // Swiping to delete the item
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // delete from firestore
            db.collection("products").document(wishListItems[indexPath.row].docID).delete()
            
            // delete from current items
            for i in 0...items.count {
                if (items[i].docID == wishListItems[indexPath.row].docID) {
                    items.remove(at: i)
                    break
                }
            }
            let temp: Product = wishListItems[indexPath.row]
            wishListItems.remove(at: indexPath.row)
            for i in 0...wishListItems.count{
                if(temp.docID == wishListItems[i].docID){
                    wishListItems.remove(at: i)
                    break
                }
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func fetchWishList() {
        wishListItems.removeAll()
        let docRef = db.collection("users").document(user)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let stringWishList = document.data()?["wishList"] as? [String] {
                    print("Retrieved str wishlist: \(stringWishList)")
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
                                if(stringWishList.contains(product.docID)){
                                    wishListItems.append(product)
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
                                //self.myFilteredItems = self.myItems
                                // Reload the table view with the updated data
                                self.wishListTableView.reloadData()
                            }
                        }
                    }
                } else {
                    // The document does not contain a valid wishList field
                    print("Error: Document does not contain a valid wishList field")
                }
            } else {
                // An error occurred or the document does not exist
                print("Error fetching document: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        if searchText == ""{
//            myFilteredItems = wishListItems
//        }
//        else{
//            myFilteredItems = []
//            for myItem in wishListItems{
//                if myItem.name.lowercased().contains(searchText.lowercased()){
//                    myFilteredItems.append(myItem)
//                }
//            }
//        }
//        self.wishListTableView.reloadData()
//    }

}
