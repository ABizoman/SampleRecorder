//
//  SystemAudio.swift
//  SampleRecorder
//
//  Created by Othman on 10/04/2025.
//

import Foundation
import AVFoundation
import OSLog

class SystemAudio: ObservableObject {
    var tapID = AudioObjectID(kAudioObjectUnknown)
    var aggregateDeviceID = AudioObjectID(kAudioObjectUnknown)
    private var IOProcID: AudioDeviceIOProcID?
    private var ioBlock: AudioDeviceIOBlock?
    private var isRecording = false
    private let queue = DispatchQueue(label: "ProcessTapRecorder", qos: .userInitiated)
    
    func createSystemAudioTap() {
        
        let description = CATapDescription(stereoMixdownOfProcesses: [])
        
        AudioHardwareCreateProcessTap(description, &tapID)

        print("✅ Tap created! ID: \(tapID)")
    }
    
    func getUIDOfAudioTap() -> CFString {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioTapPropertyUID,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )

        var propertySize = UInt32(MemoryLayout<CFString>.stride)
        var tapUID: CFString = "" as CFString

        _ = withUnsafeMutablePointer(to: &tapUID) { tapUIDPointer in
            AudioObjectGetPropertyData(tapID, &propertyAddress, 0, nil, &propertySize, tapUIDPointer)
        }

        return tapUID
    }
    
    func createAggregateDevice() {
        // Get the UID of the tap you created earlier
        let tapUID = getUIDOfAudioTap()
        
        // Prepare tap description
        let tapDict: [String: Any] = [
            kAudioSubTapUIDKey as String: tapUID
        ]
        
        // Prepare aggregate device description
        let aggregateDescription: [String: Any] = [
            kAudioAggregateDeviceNameKey as String: "Aggregate Audio Device",
            kAudioAggregateDeviceUIDKey as String: UUID().uuidString,
            kAudioAggregateDeviceIsPrivateKey as String: true,
            kAudioAggregateDeviceTapListKey as String: [tapDict]
        ]
        
        // Create the aggregate device
        let status = AudioHardwareCreateAggregateDevice(aggregateDescription as CFDictionary, &aggregateDeviceID)
        
        if status == noErr {
            print("Aggregate device created! ID: \(aggregateDeviceID)")
        } else {
            print("Failed to create aggregate device. OSStatus: \(status)")
        }
    }
    
    func getAVAudioFormatOfTap() -> AVAudioFormat? {
        var propertyAddress = AudioObjectPropertyAddress(
            mSelector: kAudioTapPropertyFormat,
            mScope: kAudioObjectPropertyScopeGlobal,
            mElement: kAudioObjectPropertyElementMain
        )
        
        var asbd = AudioStreamBasicDescription()
        var propertySize = UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
        
        let status = AudioObjectGetPropertyData(tapID, &propertyAddress, 0, nil, &propertySize, &asbd)
        
        guard status == noErr else {
            print("Failed to get ASBD from tap. OSStatus: \(status)")
            return nil
        }
        
        let format = AVAudioFormat(streamDescription: &asbd)
        return format
    }
    
    func createOutputAudioFile(at url: URL) -> AVAudioFile? {
        guard let format = getAVAudioFormatOfTap() else {
            print("Could not get audio format for tap.")
            return nil
        }
        
        do {
            let file = try AVAudioFile(forWriting: url, settings: format.settings, commonFormat: format.commonFormat, interleaved: format.isInterleaved)
            print("AVAudioFile created at \(url.path)")
            return file
        } catch {
            print("Failed to create AVAudioFile: \(error.localizedDescription)")
            return nil
        }
    }

    func run(on queue: DispatchQueue, ioBlock: @escaping AudioDeviceIOBlock) {
        print("Run tap called!")
        if aggregateDeviceID == AudioObjectID(kAudioObjectUnknown) {
            print("cannot execute run function if the aggregate device doesn't exist")
            return
        }
        
        var err = AudioDeviceCreateIOProcIDWithBlock(&IOProcID, aggregateDeviceID, queue, ioBlock)
        guard err == noErr else {
            print("Failed to create device I/O proc: \(err)")
            return
        }

        err = AudioDeviceStart(aggregateDeviceID, IOProcID)
        guard err == noErr else {
            print("Failed to start audio device: \(err)")
            return
        }
    }
    
    func start() {
        guard !isRecording else {
            print("start function called while already recording")
            stop()
            return
        }

        createSystemAudioTap()
        createAggregateDevice()
        
        let format = getAVAudioFormatOfTap()

        print("Using audio format: ", format!)
        
        let path = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)
        let downloadsDir = path[0]
        let tempFileName = UUID().uuidString + ".m4a"
        let tempAudioURL = downloadsDir.appendingPathComponent(tempFileName)

        let file = createOutputAudioFile(at: tempAudioURL)
        
        run(on: queue) { [weak self] inNow, inInputData, inInputTime, outOutputData, inOutputTime in
            guard let self, let currentFile = file else { return }
            do {
                guard let buffer = AVAudioPCMBuffer(pcmFormat: format!, bufferListNoCopy: inInputData, deallocator: nil) else {
                    print( "Failed to create PCM buffer" )
                    return
                }

                try currentFile.write(from: buffer)
            } catch {
                print("there was an error trying to write to the file: \(error)")
            }
        }
        isRecording = true
    }
    
    func stop() {
        guard isRecording else {
            print("stop function called while not recording")
            return
        }
        if aggregateDeviceID != AudioObjectID(kAudioObjectUnknown) {
            var err = AudioDeviceStop(aggregateDeviceID, IOProcID)
            if err != noErr { print("Failed to stop aggregate device: \(err)") }

            if let IOProcID {
                err = AudioDeviceDestroyIOProcID(aggregateDeviceID, IOProcID)
                if err != noErr { print("Failed to destroy device I/O proc: \(err)") }
            }

            err = AudioHardwareDestroyAggregateDevice(aggregateDeviceID)
            if err != noErr {
                print("Failed to destroy aggregate device: \(err)")
            }
        }

        if tapID != AudioObjectID(kAudioObjectUnknown){
            let err = AudioHardwareDestroyProcessTap(tapID)
            if err != noErr {
                print("Failed to destroy audio tap: \(err)")
            }
        }
        isRecording = false
    }
}
