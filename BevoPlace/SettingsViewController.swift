//
//  SettingsViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 10/17/23.
//

import UIKit
import AVFoundation
import Firebase

protocol loadSettings{
    func loadUserSettings()
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var lightModeLabel: UILabel!
    @IBOutlet weak var soundModeLabel: UILabel!
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBOutlet weak var soundModeSwitch: UISwitch!
    @IBOutlet weak var statusLabel: UILabel!
    
    
    var audioPlayer: AVAudioPlayer?
    var firestore: Firestore!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveChangesButton.layer.cornerRadius = 10
        lightModeLabel.text = "Light Mode Activated:"
        soundModeLabel.text = "Sound Off:"
        firestore = Firestore.firestore()
        self.lightModeSwitch.isOn = UserSettingsManager.shared.darkModeEnabled
        self.soundModeSwitch.isOn = UserSettingsManager.shared.soundEnabled
    }
    
    @IBAction func onLightModeSwitched(_ sender: UISwitch) {
        lightModeLabel.text = "Dark Mode Activated:"
        UserSettingsManager.shared.darkModeEnabled = sender.isOn
        UserSettingsManager.shared.applyUserSettings()
    }
    
    @IBAction func onSoundModeSwitched(_ sender: UISwitch) {
        soundModeLabel.text = sender.isOn ? "Sound On:" : "Sound Off:"
        
        UserSettingsManager.shared.soundEnabled = sender.isOn
        UserSettingsManager.shared.applyUserSettings()
    }
    
    @IBAction func onSaveChangesButtonPressed(_ sender: Any) {
        saveUserSettings()
        statusLabel.text = "Settings updated!"
        
    }
    
    func saveUserSettings() {
        // Assuming you have a way to identify the current user (e.g., authentication)
        // Replace "currentUserID" with the actual user ID or a unique identifier for the user.
        let currentUserID = user
        
        // Update and save user settings in Firestore
        firestore.collection("user_settings").document(currentUserID).setData([
            "darkMode": lightModeSwitch.isOn,
            "soundOn": soundModeSwitch.isOn
        ])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "helpSegue",
           let destination = segue.destination as? HelpViewController
        {

        }
    }

}
