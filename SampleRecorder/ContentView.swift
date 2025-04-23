//
//  ContentView.swift
//  SampleRecorder
//
//  Created by Othman on 07/04/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedProcess: Processes = .WholeSystem
    @StateObject private var audioRecording = AudioRecording()
    @StateObject private var systemAudio = SystemAudio()
    
    
    var body: some View {

    
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text("Start Recording")
                    .font(.headline)
                Button(action: systemAudio.start) {
                    Image(systemName: "record.circle")
                        .imageScale(.large)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                Button(action: audioRecording.playAudio) {
                    Image(systemName: "play.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                Button(action: audioRecording.pauseAudio) {
                    Image(systemName: "pause.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                Button(action: systemAudio.createSystemAudioTap) {
                    Image(systemName: "button.horizontal.fill")
                        .imageScale(.large)
                }
            }
            
            Picker("Record Audio From:", selection: $selectedProcess) {
                ForEach(Processes.allCases) { process in
                    Text(process.rawValue).tag(process)
                }
            }
            .frame(minWidth: 0,maxWidth: 300)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
