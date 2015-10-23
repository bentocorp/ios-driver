//
//  SoundEffect.swift
//  BentoDriver
//
//  Created by Joseph Lau on 10/23/15.
//  Copyright © 2015 Joseph Lau. All rights reserved.
//

import Foundation
import AVFoundation

public class SoundEffect {
    static let sharedPlayer = SoundEffect()
    public var audioPlayer: AVAudioPlayer!
}

extension SoundEffect {
    public func playSound(sound: String) {
        
        let soundPath = NSBundle.mainBundle().pathForResource(sound, ofType: "wav")!
        let soundURL = NSURL(fileURLWithPath: soundPath)
        
        // play audio
        do {
            let sound = try AVAudioPlayer(contentsOfURL: soundURL)
            self.audioPlayer = sound
            sound.play()
        } catch {
            // couldn't load file, handle error
        }
    }

}