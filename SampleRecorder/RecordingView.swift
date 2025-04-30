//
//  RecordingView.swift
//  SampleRecorder
//
//  Created by Othman on 30/04/2025.
//

import SwiftUI

struct RecordingStatusBarView: View {
    @Binding var isRecording: Bool
    @Binding var recordingTime: TimeInterval // passed in from a timer
    var stopAction: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Stop Button
            Button(action: stopAction) {
                Text("Stop")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .foregroundColor(.black)
                    .clipShape(Capsule())
            }
            
            // Timer
            Text(timeString(from: recordingTime))
                .monospacedDigit()
                .foregroundColor(.orange)
                .font(.system(size: 16, weight: .medium))
            
            // Animated Bars
            WaveformView()
                .frame(height: 20)
                .frame(maxWidth: 150)
            
            // Recording Status
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.red, lineWidth: 1)
                            .scaleEffect(1.5)
                            .opacity(0.4)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isRecording)
                    )
                Text("Recording")
                    .foregroundColor(.orange)
                    .fontWeight(.semibold)
            }
        }
        .padding()
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    func timeString(from time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct WaveformView: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<20, id: \.self) { bar in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.orange)
                    .frame(width: 3, height: CGFloat.random(in: 10...20))
                    .animation(Animation.linear(duration: 0.5).repeatForever().delay(Double(bar) * 0.05), value: phase)
            }
        }
        .onAppear {
            phase += 1
        }
    }
}

struct NewView: View {
    @State private var isRecording = true
    @State private var time: TimeInterval = 36
    
    var body: some View {
        RecordingStatusBarView(isRecording: $isRecording, recordingTime: $time) {
            // Stop recording logic
            isRecording = false
        }
    }
}

#Preview {
    NewView()
}
