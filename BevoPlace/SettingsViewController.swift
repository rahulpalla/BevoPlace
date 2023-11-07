//
//  SettingsViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 10/17/23.
//

import UIKit
import AVFoundation

class SettingsViewController: UIViewController {

    @IBOutlet weak var lightModeLabel: UILabel!
    @IBOutlet weak var soundModeLabel: UILabel!
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var saveChangesButton: UIButton!
    var audioPlayer: AVAudioPlayer?
    
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
    
    @IBAction func onSoundModeSwitched(_ sender: UISwitch) {
        if sender.isOn {
            soundModeLabel.text = "Sound On:"
            playThemeSong()
        } else {
            soundModeLabel.text = "Sound Off:"
            stopThemeSong()
        }
    }
    
    func playThemeSong() {
        guard let url = Bundle.main.url(forResource: "TexasLaunchSound", withExtension: "mp3") else {
            print("Theme song not found")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Play on loop indefinitely
            audioPlayer?.play()
        } catch {
            print("Error playing theme song: \(error.localizedDescription)")
        }
    }

    func stopThemeSong() {
        audioPlayer?.stop()
        audioPlayer = nil
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
