//
//  Record.swift
//  SampleRecorder
//
//  Created by Othman on 08/04/2025.
//

import Foundation
import SwiftUI
import AVFoundation
import CoreAudio
import AudioToolbox

class AudioRecording: ObservableObject {
    var recorder: AVAudioRecorder?
    var AudioPlayer: AVAudioPlayer?
    @Published var isRecording = false
    @Published var recordingURL: URL!
    @Published var isReadyToPlay = false
    @Published var isPlaying = false
    
    func PrepareToRecord() {
        pauseAudio()
        isReadyToPlay = false
        
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
//        // opens the new file in the finder
//        NSWorkspace.shared.activateFileViewerSelecting([recordingURL])
        
        initialiseAudioPlayer()
    }
    
    func initialiseAudioPlayer () {
        do {
            AudioPlayer = try AVAudioPlayer(contentsOf: recordingURL!)
            AudioPlayer?.prepareToPlay()
            isReadyToPlay = true
        } catch {
            print("Setting up the audio player failed: \(error)")
        }
    }
    
    func playAudio() {
        if !isReadyToPlay {
            print("the Audio Player needs to be initialised before playing audio")
            return
        }
        AudioPlayer?.play()
        isPlaying = true
    }
    
    func pauseAudio() {
        if !isReadyToPlay {
            print("the Audio Player needs to be initialised before pausing audio")
            return
        }
        if isPlaying {
            AudioPlayer?.pause()
            isPlaying = false
        }
    }
}
