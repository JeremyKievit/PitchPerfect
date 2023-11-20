//
//  PlaySoundsViewController + Audio.swift
//  PitchPerfect
//
//
//  Copyright © 2016 Udacity. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: PlaySoundsViewController: AVAudioPlayerDelegate

// This extension of the PlaySoundsVC allows the main class to focus on audio playback while the extension focuses on handling the audio itself

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    
    // MARK: Alerts
    // Contains static string constants for alert messages based on the recording state
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // MARK: PlayingState
    
    // Raw vaues corresponding to sender to sender tags
    enum PlayingState { case playing, notPlaying }
    
    // MARK: Audio Functions

    // Initialize (recording) audio file
    func setupAudio() {
        do {
            // Try creating an AVAudioFile object for reading from the recordedAudioURL
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            // An error occurred during initialization. Show an alert with the error details
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    // Audio playback function
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        
        // Initialize audio engine components
        audioEngine = AVAudioEngine()

        // Initialize node for playing audio
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)

        // Initialize node for adjusting rate/pitch
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        // Initialize node for echo
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        // Initialize node for reverb
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        // Connect nodes
        if echo == true && reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb == true {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        // Stops the audio player node to ensure it starts playing from the beginning
        audioPlayerNode.stop()
        
        // Plays the engine by scheduling the audio file for playback on the audio player node
        audioPlayerNode.scheduleFile(audioFile, at: nil) {
            // Scheduling is complete
            
            // Calculating the delay before stopping the audio playback based on the rate and the remaining duration of the audio file
            var delayInSeconds: Double = 0
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
                
                // Check if a playback rate is provided
                if let rate = rate {
                    // Calculate delay considering playback rate
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                } else {
                    // Calculate delay without considering playback rate
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            // Schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoop.Mode.default)
        } // End of completion closure for audio file scheduling and playback handling
        
        do {
            // Starting the audio engine to processing and managing the audio data
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
            return
        }
        
        // Playing the recording!
        audioPlayerNode.play()
    }
    
    // Stop audio playback function
    @objc func stopAudio() {
        // Stop the audio player node if it exists
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        // Invalidate the stop timer if it's set
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        // Configure UI for not playing state
        configureUI(.notPlaying)
                        
        // Stop and reset the audio engine if it exists
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    // MARK: Connect List of Audio Nodes
    
    // Connects a sequence of AVAudioNodes in a chain
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    // MARK: UI Functions

    // Configures UI elements based on the provided play state
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            stopButton.isEnabled = true
        case .notPlaying:
            setPlayButtonsEnabled(true)
            stopButton.isEnabled = false
        }
    }
    
    // Sets the enabled state of play-related buttons
    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        vaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }

    // Shows an alert with the given title and message
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
