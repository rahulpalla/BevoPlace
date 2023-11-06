//
//  SettingsViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 10/17/23.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var lightModeLabel: UILabel!
    @IBOutlet weak var soundModeLabel: UILabel!
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lightModeLabel.text = "Light Mode Activated:"
        soundModeLabel.text = "Sound Off:"
    }
    
    @IBAction func onLightModeSwitched(_ sender: UISwitch) {
        lightModeLabel.text = "Dark Mode Activated:"
        // add in functionality for dark mode
        
        if #available(iOS 13.0, *) {
             let appDelegate = UIApplication.shared.windows.first
                 if sender.isOn {
                    appDelegate?.overrideUserInterfaceStyle = .dark
                      return
                 }
             appDelegate?.overrideUserInterfaceStyle = .light
             return
        }
    }
    
    @IBAction func onSoundModeSwitched(_ sender: Any) {
        soundModeLabel.text = "Sound On:"
        // add in functionality for sound on
    }
    
    @IBAction func onSaveChangesButtonPressed(_ sender: Any) {
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
