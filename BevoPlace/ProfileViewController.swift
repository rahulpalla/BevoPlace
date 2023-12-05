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
    
    //Outlets
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var otherInfoTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var displayEmailLabel: UILabel!
    
    override func viewDidLoad() {
        saveChangesButton.layer.cornerRadius = 10
        logOutButton.layer.cornerRadius = 10
        //Getting user info from firebase
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
    
    //Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    //Updates user information
    @IBAction func onSaveChangesButtonPressed(_ sender: Any) {
        if displayNameTextField.text == "" {
            displayNameTextField.text = displayNameTextField.placeholder
        }
        if otherInfoTextField.text == "" {
            otherInfoTextField.text = otherInfoTextField.placeholder
        }
        let docRef = db.collection("users").document(user)
        docRef.updateData([
            "name" : self.displayNameTextField.text!,
            "number" : self.otherInfoTextField.text!
        ])
        self.showAlert(message: "Successfully Updated!")
    }
    
    //Logs out user
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }
    
    //Alerts
    func showAlert(message: String) {
        let alertController = UIAlertController(
            title: "Profile",
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
