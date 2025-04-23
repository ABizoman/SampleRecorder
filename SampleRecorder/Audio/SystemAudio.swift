//
//  SystemAudio.swift
//  SampleRecorder
//
//  Created by Othman on 10/04/2025.
//

import Foundation
import AVFoundation

class SystemAudio: ObservableObject {
    
    func createSystemAudioTap() throws {
        
        let description = CATapDescription(stereoMixdownOfProcesses: [])
        var tapID = AudioObjectID(kAudioObjectUnknown)
        let Tap = AudioHardwareCreateProcessTap(description, &tapID)
        
        guard Tap == noErr else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(Tap), userInfo: nil)
        }

        print("✅ Tap created! ID: \(tapID)")
    }
    
    func createAggregateDeviceTap() throws {
        let description = [kAudioAggregateDeviceNameKey: "Aggregate Audio Device", kAudioAggregateDeviceUIDKey: UUID().uuidString]
        var id: AudioObjectID = 0
        let AggregateDevice = AudioHardwareCreateAggregateDevice(description as CFDictionary, &id)
    }


}
