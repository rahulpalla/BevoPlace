//
//  ProfileViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 10/17/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameTextField: UITextField!
    
    
    @IBOutlet weak var otherInfoTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    @IBOutlet weak var displayEmailLabel: UILabel!
    @IBOutlet weak var profileStatusLabel: UILabel!
    
    override func viewDidLoad() {
        let docRef = db.collection("users").document(user)
        docRef.getDocument{(document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing: )) ?? "nil"
                self.displayNameTextField.placeholder = document["name"] as? String
                self.displayEmailLabel.text = document["email"] as? String
                self.otherInfoTextField.placeholder = document["number"] as? String
                print("Document data: \(dataDescription)")
            }
            else{
                print("Document does not exist")
            }
        }
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func onSaveChangesButtonPressed(_ sender: Any) {
        if displayNameTextField.text == "" {
            self.profileStatusLabel.text = "Please enter a display name"
        } else if otherInfoTextField.text == "" {
            self.profileStatusLabel.text = "Please enter contact information"
        }
        else{
            self.profileStatusLabel.text = "Successfully updated!"
            let docRef = db.collection("users").document(user)
            docRef.updateData([
                "name" : self.displayNameTextField.text!,
                "number" : self.otherInfoTextField.text!
            ])
            
        }
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
