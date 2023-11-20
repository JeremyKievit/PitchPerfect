//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Jeremy Kievit on 7/15/20.
//  Copyright © 2020 Com.JeremyKievit. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder!
    
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopRecordingButton.isEnabled = false
    }

    // Action when record button is pressed
    @IBAction func RecordAudio(_ sender: Any) {
        configureUI(isRecording: true)
        
        // Set up audio recording file path
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))

        // Configure audio session and start recording
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)

            try audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            
        } catch {
            print("Error: \(error)")
        }
    }   
    
    // Action when stop recording button is pressed
    @IBAction func stopRecording(_ sender: Any) {
        audioRecorder.stop()
        configureUI(isRecording: false)
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // Update UI based on recording state
    func configureUI(isRecording: Bool) {
        let label = isRecording ? "Recording in progress" : "Tap to record"
        recordingLabel.text = label
        recordButton.isEnabled = !isRecording
        stopRecordingButton.isEnabled = isRecording
    }
    
    // Delegate method called when recording finishes
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("Recording was not successful")
        }
    }
    
    // Prepare for segue to pass recorded audio URL to next view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
}

