//
//  ProfileViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 10/17/23.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var displayEmailTextField: UITextField!
    @IBOutlet weak var otherInfoTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    @IBOutlet weak var logOutButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSaveChangesButtonPressed(_ sender: Any) {
        // add functionality to change info in firebase
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true)
        } catch {
            print("Sign out error")
        }
    }

    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
