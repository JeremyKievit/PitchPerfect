# Pitch Perfect

Pitch Perfect is an AV Foundation application built with Swift that takes advantage of AVAudioRecorder to record and modify audio.

<img src="/Assets/Images/RecordSoundsVC_1.png" height="49%" width="30%"> <img src="/Assets/Images/RecordSoundsVC_2.png" height="49%" width="30%"> <img src="/Assets/Images/PlaySoundsVC.png" height="49%" width="30%">

## Implementation

The app records audio and allows the user to make simple modifications to the recording. It separates audio recording and playback into two simple view controllers, RecordSoundsViewController and PlaySoundsViewController. 

- **RecordSoundsViewController** has a record button and a second button to stop the recording, along with the label that reflects the recording state. After the stop button is pressed,  RecordSoundsViewController automatically performs a segue to PlaySoundsViewController using the audioRecorderDidFinishRecording() method in AVAudioRecorderDelegate protocol.
- **RecordSoundsViewController** has six buttons for modifying the audio. They are slow, fast, chipmunk, Darth Vader, echo, and reverb. The audio is manipulated by adjusting the rate, pitch, echo and reverb properties of the AVAudioEngine().

# Libraries and Frameworks
UIKit
AVFoundation

# Installation
Download the zip folder and open the file PitchPerfect.xcodeproj in Xcode.

# License
All code is original and was written by me. The project was developed as part of the iOS Developer Nanodegree Program, in accordance with the [project rubric](https://www.google.com/url?q=https://docs.google.com/document/d/1LlcUT90j-ItbRQpB3ivLHwjP-KgKOUdoOLpz0WirpSo/pub&sa=D&source=docs&ust=1699838777346607&usg=AOvVaw2gJNJaxWYVNDvYQwU5k8yr).
