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
        }
        
        @IBAction func signupButtonPressed(_ sender: Any) {
            //custom error messages for empty fields
            if signUpEmailTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter a username"
            } else if signUpPasswordTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter a password"
            } else if signUpConfirmPasswordTextField.text == "" {
                self.signUpStatusLabel.text = "Please confirm password"
            } else if signUpPasswordTextField.text != signUpConfirmPasswordTextField.text {
                self.signUpStatusLabel.text = "Passwords do not match"
            } else {
                // if sign up error, display error
                // otherwise, show success message and move to main view controller (i.e. pizza table view)
                Auth.auth().createUser(withEmail: signUpEmailTextField.text!, password: signUpPasswordTextField.text!) { authResult, error in
                    if let error = error as NSError? {
                        self.signUpStatusLabel.text = "\(error.localizedDescription)"
                    } else {
                        // extra: shows successful login message and delays for 0.5 seconds so message can be seen
                        self.signUpStatusLabel.text = "Success!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.performSegue(withIdentifier: "signUpToHomeSegue", sender: self)
                        }
                    }
                }
            }
        
        }


}
