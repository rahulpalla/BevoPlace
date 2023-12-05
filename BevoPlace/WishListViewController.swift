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
    
    //Outlets
    @IBOutlet weak var wishListTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Filtered Wish List array for search bar
    var filteredWishList : [Product] = wishListItems
    
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
        filteredWishList = wishListItems
        
        updateBackground()

        UserSettingsManager.shared.onChange = { [weak self] in
            DispatchQueue.main.async {
                self?.updateBackground()
            }
        }
        
    }
    
    //Updating background
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
    
    //Refresh Control
    @objc func handleRefreshControl(_ myRefreshControl: UIRefreshControl) {
       // Update your content…
        self.fetchWishList()
        self.wishListTableView.reloadData()
       // Dismiss the refresh control.
       DispatchQueue.main.async {
          myRefreshControl.endRefreshing()
       }
    }
    
    //Table View function
    override func viewWillAppear(_ animated: Bool) {
        wishListTableView.reloadData()
    }
    
    //Table View function
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWishList.count
    }
        
    //Table View function
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WishListItemCell", for: indexPath) as! WishListProductCell
        
        let row = indexPath.row
        
        //Stylings for cells
        cell.wishProductImage.image = filteredWishList[row].image
        cell.wishLeaseBuyLabel.layer.cornerRadius = 10
        cell.wishLeaseBuyLabel.layer.masksToBounds = true
        cell.wishProductTitleLabel?.text = filteredWishList[row].name
        cell.wishProductCategoryLabel.text = "\(String(describing: filteredWishList[row].category))"

        let price = round(filteredWishList[row].price * 100.0) / 100.0
        if (!filteredWishList[row].lease) {
            // Buy Item interface
            cell.wishDummyLeaseLengthLabel.isHidden = true
            cell.wishProductPriceLabel.text = "$\(String(price))"
            cell.wishLeaseLengthLabel.text = ""
            cell.wishLeaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.wishDummyLeaseLengthLabel.isHidden = false
            cell.wishProductPriceLabel.text = "$\(String(price))/\(filteredWishList[row].period)"
            cell.wishLeaseLengthLabel.text = "\(filteredWishList[row].numPeriods) \(filteredWishList[row].period)s"
            cell.wishLeaseBuyLabel.text = "Lease"
        }
        cell.layer.cornerRadius = 15
        
        return cell
    }
    
    //Segue
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
            
            let temp: Product = filteredWishList[indexPath.row]
            filteredWishList.remove(at: indexPath.row)
            var i = 0
            while(i < wishListItems.count){
                if(temp.docID == wishListItems[i].docID){
                    wishListItems.remove(at: i)
                    break
                }
                i+=1
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            var stringWishList = [String]()
            for prod in wishListItems{
                stringWishList.append(prod.docID)
            }
            let docRef = db.collection("users").document(user)
            docRef.updateData(["wishList": stringWishList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        // Handle the error, show an alert if necessary
                    } else {
                        // Item added to Wish List successfully, show an alert
                        self.showAlert(message: "Item removed from Wish List!")
                    }
                }
        }
    }
    
    //Fetching wishlist
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
                                self.filteredWishList = wishListItems
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
    
    //Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Search bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            filteredWishList = wishListItems
        }
        else{
            filteredWishList = []
            for myItem in wishListItems{
                if myItem.name.lowercased().contains(searchText.lowercased()){
                    filteredWishList.append(myItem)
                }
            }
        }
        self.wishListTableView.reloadData()
    }
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(
            title: "Wish List",
            message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(
            title: "OK",
            style: .default,
            handler: nil
        )

        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

}
