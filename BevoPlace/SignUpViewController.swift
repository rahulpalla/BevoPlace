//
//  SignUpViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 10/17/23.
//

import UIKit
import FirebaseAuth

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
//            if signUpEmailTextField.text == "" {
//                self.signUpStatusLabel.text = "Please enter a username"
//            } else if signUpPasswordTextField.text == "" {
//                self.signUpStatusLabel.text = "Please enter a password"
//            } else if signUpConfirmPasswordTextField.text == "" {
//                self.signUpStatusLabel.text = "Please confirm password"
//            } else if signUpPasswordTextField.text != signUpConfirmPasswordTextField.text {
//                self.signUpStatusLabel.text = "Passwords do not match"
//            } else {
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
            //}
        
        }


}
