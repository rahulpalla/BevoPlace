//
//  WishlistViewController.swift
//  BevoPlace
//
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class WishListViewController: UIViewController, ObservableObject, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var wishListItems = [Product]()
    var filteredWishListItems : [Product] = items
        
    @IBOutlet weak var wishListTableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let itemCellIdentifier = "ItemCell"
    
    let myRefreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        myRefreshControl.addTarget(self, action: #selector( handleRefreshControl(_:)), for: .valueChanged)
        self.wishListTableView.addSubview(self.myRefreshControl)
        
        self.fetchWishList()
        self.wishListTableView.reloadData()
        // Important setup for Table View.
        wishListTableView.delegate = self
        wishListTableView.dataSource = self
        filteredWishListItems = wishListItems
        
        wishListTableView.layer.cornerRadius = 10.0
        
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
        updateBackground()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredWishListItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = wishListTableView.dequeueReusableCell(withIdentifier: itemCellIdentifier, for: indexPath as IndexPath) as! ProductCell
        
        
        
        let row = indexPath.row
        
//        // check if we have the image saved locally
//        let imgPath = "image/\(items[row].docID)/productPhoto"
//
//         download image from firebase with the url
//        let pathReference = Storage.storage().reference(withPath: imgPath)
//        pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
//            if let error = error {
//                // Uh-oh, an error occurred!
//                print(error.localizedDescription)
//            } else {
//                cell.ProductImage.image = UIImage(data: data!)
//            }
//        }
        cell.ProductImage.image = filteredWishListItems[row].image
        
        cell.leaseBuyLabel.layer.cornerRadius = 10
        cell.leaseBuyLabel.layer.masksToBounds = true
        cell.productTitleLabel?.text = filteredWishListItems[row].name
        cell.productCategoryLabel.text = "\(String(describing: filteredWishListItems[row].category))"
        
        let price = round(filteredWishListItems[row].price * 100.0) / 100.0
        if (!filteredWishListItems[row].lease) {
            // Buy Item interface
            cell.productPriceLabel.text = "$\(String(price))"
            cell.leaseLengthLabel.text = ""
            cell.dummyLeaseLengthLabel.isHidden = true
            cell.leaseBuyLabel.text = "Buy"
        } else {
            // Lease Item interface
            cell.dummyLeaseLengthLabel.isHidden = false
            cell.productPriceLabel.text = "$\(String(price))/\(filteredWishListItems[row].period)"
            cell.leaseLengthLabel.text = "\(filteredWishListItems[row].numPeriods) \(filteredWishListItems[row].period)s"
            cell.leaseBuyLabel.text = "Lease"
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "wishListToViewItemSegue",
            let viewItemVC = segue.destination as? ViewItemViewController,
            let index = wishListTableView.indexPathForSelectedRow?.row {
            viewItemVC.delegate = self
            viewItemVC.index = index
            viewItemVC.product = items[index]
        }
    }
    
    func fetchWishList() {
        var stringWishlist = [String]()
        let docRef = db.collection("users").document(user)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing: )) ?? "nil"
                stringWishlist = document["wishlist"] as! [String]
                print("Document data: \(dataDescription)")
            }
            else{
                print("Document does not exist")
            }
        }
        for id in stringWishlist{
            for item in items{
                if(id == item.docID){
                    wishListItems.append(item)
                }
            }
        }
        self.filteredWishListItems = wishListItems
        // Download images from firebase using the image url
        for item in wishListItems {
            let imgPath = "image/\(item.docID)/productPhoto"
            let pathReference = Storage.storage().reference(withPath: imgPath)
            pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print(error.localizedDescription)
                } else {
                    item.image = UIImage(data: data!)!
                }
            }
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == ""{
            filteredWishListItems = items
        }
        else{
            filteredWishListItems = []
            for item in items{
                if item.name.lowercased().contains(searchText.lowercased()){
                    filteredWishListItems.append(item)
                }
            }
        }
        self.wishListTableView.reloadData()
    }
}
