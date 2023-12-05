//
//  ViewController.swift
//  BevoPlace
//
//  Created by Rahul Palla on 9/28/23.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
var user: String = ""
var darkModeEnabled: Bool = false
var soundEnabled: Bool = false
var userSettings: [String: Any] = [:]
class LoginViewController: UIViewController {
    
    //Outlets
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
        loginButton.layer.cornerRadius = 10
        signUpButton.layer.cornerRadius = 10
        
//            Auth.auth().addStateDidChangeListener() {
//                (auth,user) in
//                if user != nil {
//                    self.performSegue(withIdentifier: "loginToTabSegue", sender: nil)
//                    self.emailTextField.text = nil
//                    self.passwordTextField.text = nil
//                }
//            }
    }
    
    //Dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
         self.view.endEditing(true)
    }
        
    //Login button pressed
    @IBAction func loginButtonPressed(_ sender: Any) {
        //Empty email
        if emailTextField.text == "" {
            self.errorLabel.text = "Please enter your username"
            let controller = UIAlertController(
                title: "Log In Error",
                message: "Please Enter Your Username",
                preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller, animated: true)
            //Empty password
        } else if passwordTextField.text == "" {
            self.errorLabel.text = "Please enter your password"
            let controller = UIAlertController(
                title: "Log In Error",
                message: "Please Enter Your Password",
                preferredStyle: .alert)
            
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(controller, animated: true)
        }
        else {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
                (authResult,error) in
                //Error
                if let error = error as NSError? {
                    self.errorLabel.text = "\(error.localizedDescription)"
                    let controller = UIAlertController(
                        title: "Log In Error",
                        message: error.localizedDescription,
                        preferredStyle: .alert)
                    
                    controller.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(controller, animated: true)
                } else {
                    //Logging in
                    user = self.emailTextField.text!
                    self.errorLabel.text = ""
                    self.emailTextField.text = ""
                    self.passwordTextField.text = ""
                    self.loadUserSettingsAndSegue()
                }
            }
        }
    }
    
    func loadUserSettingsAndSegue() {
        // Access the Firestore document containing user settings
        Firestore.firestore().collection("user_settings").document(user).getDocument { (document, error) in
            if let document = document, document.exists {
                if let data = document.data() {
                    // Fetch user settings, such as dark mode and sound preferences
                    if let isDarkModeOn = data["darkMode"] as? Bool {
                        UserSettingsManager.shared.darkModeEnabled = isDarkModeOn
                    }
                    if let isSoundOn = data["soundOn"] as? Bool {
                        UserSettingsManager.shared.soundEnabled = isSoundOn
                    }
                }
            }
            UserSettingsManager.shared.applyUserSettings()
            // Continue with the segue once user settings are loaded
            self.performSegue(withIdentifier: "loginToTabSegue", sender: nil)
        }
    }
    
}
