//
//  SignUpViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 10/17/23.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseCore

class SignUpViewController: UIViewController {

    @IBOutlet weak var signUpEmailTextField: UITextField!
        
        
        
        @IBOutlet weak var signUpPasswordTextField: UITextField!
        
        
        
        @IBOutlet weak var signUpConfirmPasswordTextField: UITextField!
        
        
        
        @IBOutlet weak var signUpPageButton: UIButton!
        
        @IBOutlet weak var signUpStatusLabel: UILabel!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            signUpPasswordTextField.isSecureTextEntry = true
            signUpConfirmPasswordTextField.isSecureTextEntry = true
        }
        
        @IBAction func signupButtonPressed(_ sender: Any) {
            //custom error messages for empty fields
            if signUpEmailTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter your username"
            } else if signUpPasswordTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter your password"
            }
            else {
                Auth.auth().createUser(withEmail: signUpEmailTextField.text!, password: signUpPasswordTextField.text!) { authResult, error in
                    if let error = error as NSError? {
                        self.signUpStatusLabel.text = "\(error.localizedDescription)"
                    } else {
                        self.signUpStatusLabel.text = "Success!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.performSegue(withIdentifier: "signUpToTabSegue", sender: self)
                        }
                    }
                }
            }
        
        }


}
