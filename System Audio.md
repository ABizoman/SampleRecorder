04/04/2025

[AudioCap repo](https://github.com/insidegui/AudioCap)

In macOS14.2, apple introduced a [new CoreAudio  API](https://developer.apple.com/documentation/coreaudio/capturing-system-audio-with-core-audio-taps) that allows any app to capture audio from other apps or the entire system once the specific app or apps have granted permission. 

A **Core Audio Tap** can be used as an input in aggregate device much like a microphone.
'You create a tap by passing a [`CATapDescription`](https://developer.apple.com/documentation/coreaudio/catapdescription) to [`AudioHardwareCreateProcessTap(_:_:)`](https://developer.apple.com/documentation/coreaudio/catapdescription). This returns an `AudioObjectID` for the new tap object. You can destroy a tap using [`AudioHardwareDestroyProcessTap(_:)`](https://developer.apple.com/documentation/coreaudio/audiohardwaredestroyprocesstap(_:)):'

*looking trough github* there are a lot of neat audio utilities out there.

I built the audio cap app on my computer. This shit is ass. (or i did something wrong)
![[Pasted image 20250404125218.png]]
like bro i want apps not processes

9/05/2025
rn im going to quickly use [AVAudioRecorder](https://developer.apple.com/documentation/avfaudio/avaudiorecorder) to record audio and create a file - learn how to do the easy part first ykwims.

### How to record audio using AVAudioRecorder
---
[article](https://www.hackingwithswift.com/example-code/media/how-to-record-audio-using-avaudiorecorder)
- import `AVFoundation`
You need 3 properties in the view controller:
- recordButton
- AudioSession - to manage recording
- audioRecorder - to handle the actual reading and saving of data

##### user permission
- add 
	- 'Privacy - Microphone Usage Description' to Info - custom macOS Application target properties
	- audio Input to signing capabilities



To **convert audio** to whatever format i want i can use:[`AVAssetExportSession`](https://developer.apple.com/documentation/avfoundation/avassetexportsession)


##### and then magic:
```swift
import Foundation
import SwiftUI
import AVFoundation

class AudioRecording: ObservableObject {
    var recorder: AVAudioRecorder?
    @Published var isRecording = false
    @Published var recordingURL: URL?
    
    func PrepareToRecord() {
        
        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 320000,
            AVLinearPCMBitDepthKey: 16
        ]
        
        let path = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        let downloadsDir = path[0]
        let tempFileName = UUID().uuidString + ".m4a"
        let tempAudioURL = downloadsDir.appendingPathComponent(tempFileName)
        
        do {
            recorder = try AVAudioRecorder (url: tempAudioURL, settings: settings)
            recorder?.prepareToRecord()
            recordingURL = tempAudioURL
        } catch {
            print("Setting up the recorder failed: \(error)")
        }
    }
    
    func startRecording() {
        !isRecording ? record() : stopRecording()
    }
    
    func record() {
        PrepareToRecord()
        recorder?.record()
        print("started recording")
        isRecording = true
    }
    
    func stopRecording() {
        recorder?.stop()
        isRecording = false
        print("Stopped recording")
        // give the user the file and options to download in the UI
    }
}
```

### How To Use Initialisers 
---
[video](https://www.youtube.com/watch?v=ElfPQZ9MVTQ) was useless so just used clause
```swift
[`init(url: URL, settings: [String : Any]) throws`]
```
- the initialiser takes 2 parameters and can throw an error
- you must use **try** when calling this initialiser because it can throw an error
- you must **wrap** the call in a **do-catch** block or user alternative handling approaches


### AVAudioEngine
---
Key components:
	- **AVAudioEngine:** central object that manages the audio graph - controls start, pause, stop, schedules rendering and manages the audio session
	- **AVAudioNodes:** building blocks of the avAudioEngine:
		- **AVAudioInputNode:** represent's an audio source
		- **AVAudioOutputNode:** Represents the output destination
		- **AVAudioPlayerNode:** Allows you to schedule and play audio buffers or audio files
		- **AVAudioMixerNode:** Used to mix multiple audio signals together. Every engine has a main mixer node which acts as an internal mixer.
		- **AVAudioUnitEffect & AVAudioUnitEQ (and more...)**: Provide audio processing effects
	- **AVAudioFormat:** describes the audio format for a node, ensuring compatibility of nodes when connecting them

#### Signal Flow

The Engine starts with the input node and ends with the output node. In between, you can insert various processing nodes that modify or analyse the signal.
**Connecting Nodes:**
- Nodes are connected with a standard API using the `connect(_:to:format:)` method. 
	- note: audio format compatibility
**Taps:**
- You can install a tap on any AVAudioNode using the `installTap(onBus:bufferSize:format:block:)` method. The tap intercepts the audio passing through the node in the form of buffers (AVAudioPCMBuffer), enabling you to process, analyse or record raw audio data.

