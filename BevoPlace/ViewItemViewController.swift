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

class ViewItemViewController: UIViewController {
    
    
    var delegate:UIViewController!
    var index: Int!
    var product: Product!
    

    @IBOutlet weak var titleLabel: UILabel!
    
    
    
    @IBOutlet weak var itemImage: UIImageView!
    
    
    @IBOutlet weak var displayNameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var contactLabel: UILabel!
    
    
    override func viewDidLoad() {
        let docRef = db.collection("users").document(product.userID)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing: )) ?? "nil"
                print("Document data: \(dataDescription)")
                self.titleLabel.text = self.product.name
                //itemImage code
                self.displayNameLabel.text = document["name"] as? String
                self.emailLabel.text = self.product.userID
                self.contactLabel.text = document["numer"] as? String
            }
            else{
                print("Document does not exist")
            }
        }
        super.viewDidLoad()
       
        
        
        
        // Do any additional setup after loading the view.
    }
    
    
    



}
