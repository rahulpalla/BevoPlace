//
//  UserSettingsManager.swift
//  BevoPlace
//
//  Created by Khoi Nguyen on 11/7/23.
//
import UIKit
import AVFoundation

class UserSettingsManager {
    static let shared = UserSettingsManager()

    var darkModeEnabled: Bool = false {
        didSet {
            // Call the closure when the dark mode setting changes
            onChange?()
        }
    }
    
    var soundEnabled: Bool = false
    var audioPlayer: AVAudioPlayer?
    
    var onChange: (() -> Void)?
    
    func applyUserSettings() {
        // Apply dark mode settings
        if #available(iOS 13.0, *) {
            let appDelegate = UIApplication.shared.windows.first
            if darkModeEnabled {
                appDelegate?.overrideUserInterfaceStyle = .dark
                
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
                
            }
        }

        // Apply sound settings
        if soundEnabled {
            playThemeSong()
        } else {
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
}
