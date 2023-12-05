//
//  SignUpViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 10/17/23.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

let db = Firestore.firestore()
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
            signUpPageButton.layer.cornerRadius = 10
        }
    
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.view.endEditing(true)
        }
        
        @IBAction func signupButtonPressed(_ sender: Any) {
            //custom error messages for empty fields
            if signUpEmailTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter your username"
                let controller = UIAlertController(
                    title: "Sign Up Error",
                    message: "Please Enter Your Username",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            } else if signUpPasswordTextField.text == "" {
                self.signUpStatusLabel.text = "Please enter your password"
                let controller = UIAlertController(
                    title: "Sign Up Error",
                    message: "Please Enter Your Password",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            }
            else if signUpConfirmPasswordTextField.text == ""{
                self.signUpStatusLabel.text = "Please confirm your password"
                let controller = UIAlertController(
                    title: "Sign Up Error",
                    message: "Please Confirm Your Password",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            }
            else if signUpPasswordTextField.text != signUpConfirmPasswordTextField.text{
                self.signUpStatusLabel.text = "Passwords do not match"
                let controller = UIAlertController(
                    title: "Sign Up Error",
                    message: "Passwords do not match",
                    preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(controller, animated: true)
            }
            else {
                Auth.auth().createUser(withEmail: signUpEmailTextField.text!, password: signUpPasswordTextField.text!) { authResult, error in
                    if let error = error as NSError? {
                        self.signUpStatusLabel.text = "\(error.localizedDescription)"
                        let controller = UIAlertController(
                            title: "Sign Up Error",
                            message: error.localizedDescription,
                            preferredStyle: .alert)
                        
                        controller.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(controller, animated: true)
                    } else {
                        self.signUpStatusLabel.text = "Success!"
                        user = self.signUpEmailTextField.text!
                        db.collection("users").document(user).setData([
                            "name": "Set Display Name",
                            "email" : user,
                            "number": "",
                            "sound": true,
                            "theme" : true
                        ])
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.performSegue(withIdentifier: "signUpToTabSegue", sender: self)
                        }
                    }
                }
            }
        
        }

}
