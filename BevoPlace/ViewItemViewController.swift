//
//  ViewItemViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 11/7/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
class ViewItemViewController: UIViewController {
    
    
    var delegate:UIViewController!
    var index: Int!
    var product: Product!
    
    var stringWishList = [String]()
    

    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var itemImage: UIImageView!
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var contactLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var sizeLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var disLikeButton: UIButton!
    
    
    override func viewDidLoad() {
        
        itemImage.layer.cornerRadius = 15
        
        let background = UIImage(named: "towerPretty.png")

        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
                view.addSubview(imageView)
                self.view.sendSubviewToBack(imageView)
        
        let docRef = db.collection("users").document(product.userID)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing: )) ?? "nil"
                print("Document data: \(dataDescription)")
                
                self.titleLabel.text = self.product.name
                self.descriptionLabel.text = self.product.description
                self.descriptionLabel.numberOfLines = 4
                self.sizeLabel.text = self.product.size
                if (self.product.lease) {
                    self.priceLabel.text = "$\(String(self.product.price))/\(self.product.period)"
                } else {
                    self.priceLabel.text = "$\(String(self.product.price))"
                }
                
                let pathReference = Storage.storage().reference(withPath: "image/\(self.product.docID)/productPhoto")
                pathReference.getData(maxSize: 1 * 1024 * 1024 * 1024) { data, error in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.itemImage.image = UIImage(data: data!)
                    }
                    self.displayNameLabel.text = document["name"] as? String
                    self.emailLabel.text = self.product.userID
                    self.contactLabel.text = document["number"] as? String
                }
            }
            else{
                print("Document does not exist")
            }
        }
        
        super.viewDidLoad()
       
    }
    
    
    
    @IBAction func like(_ sender: Any) {
        if(!stringWishList.contains(product.docID)){
            stringWishList.append(product.docID)
            let docRef = db.collection("users").document(user)
            docRef.updateData(["wishList": self.stringWishList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        // Handle the error, show an alert if necessary
                    } else {
                        // Item added to Wish List successfully, show an alert
                        self.showAlert(message: "Item added to Wish List!")
                    }
                }
        }
        else{
            self.showAlert(message: "Item already in Wish List!")
        }
    }
    
    
    
    
    @IBAction func dislike(_ sender: Any) {
        if(stringWishList.contains(product.docID)){
            var count = 0
            for prod in stringWishList{
                if(product.docID == prod){
                    stringWishList.remove(at: count)
                }
                else{
                    count+=1
                }
            }
            let docRef = db.collection("users").document(user)
            docRef.updateData(["wishList": self.stringWishList]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        // Handle the error, show an alert if necessary
                    } else {
                        // Item added to Wish List successfully, show an alert
                        self.showAlert(message: "Item removed from Wish List!")
                    }
                }
        }
        else{
            self.showAlert(message: "Item not in Wish List!")
        }
        
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
