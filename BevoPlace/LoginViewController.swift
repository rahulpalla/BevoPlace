//
//  ViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 9/28/23.
//

import UIKit
import FirebaseAuth

var user: String = ""

class LoginViewController: UIViewController {

        @IBOutlet weak var emailTextField: UITextField!
        
        @IBOutlet weak var passwordTextField: UITextField!
        
        @IBOutlet weak var forgotPasswordButton: UIButton!
        
        @IBOutlet weak var loginButton: UIButton!
        
        @IBOutlet weak var signUpButton: UIButton!
        
        @IBOutlet weak var errorLabel: UILabel!
        
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            super.viewDidLoad()
            passwordTextField.isSecureTextEntry = true
            
            Auth.auth().addStateDidChangeListener() {
                (auth,user) in
                if user != nil {
                    self.performSegue(withIdentifier: "loginToTabSegue", sender: nil)
                    self.emailTextField.text = nil
                    self.passwordTextField.text = nil
                }
            }
        }
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
             self.view.endEditing(true)
        }
        
    @IBAction func loginButtonPressed(_ sender: Any) {
        if emailTextField.text == "" {
            self.errorLabel.text = "Please enter your username"
        } else if passwordTextField.text == "" {
            self.errorLabel.text = "Please enter your password"
        }
        else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult,error) in
                if let error = error as NSError? {
                    self.errorLabel.text = "\(error.localizedDescription)"
                } else {
                    user = self.emailTextField.text!
                    self.errorLabel.text = ""
                    self.performSegue(withIdentifier: "loginToTabSegue", sender: nil)
                }
            }
        }
    }
    
}

