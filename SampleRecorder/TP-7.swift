//
//  TP-7.swift
//  SampleRecorder
//
//  Created by Othman on 30/04/2025.
//

import SwiftUI

struct TP7View: View {
    @State private var isRecording = false
    @State private var volume: Double = 0.5 // Slider value for volume
    @State private var rotationAngle: Double = 0.0 // For animating the circle
    
    var body: some View {
        VStack(spacing: 20) {
            // Top labels
            HStack {
                Text("TP-7")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                Spacer()
                Text("B4536")
                    .font(.system(size: 12, weight: .regular))
                    .padding(5)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            .padding(.horizontal, 20)
            
            // Circular recording wheel
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
                    .rotationEffect(.degrees(rotationAngle))
                    .onAppear {
                        withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                            rotationAngle = 360
                        }
                    }
                
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Circle()
                    .fill(isRecording ? Color.red : Color.gray)
                    .frame(width: 10, height: 10)
                    .offset(x: 0, y: -20)
            }
            
            // Control buttons
            HStack(spacing: 20) {
                // Record button
                Button(action: {
                    isRecording.toggle()
                }) {
                    Circle()
                        .fill(isRecording ? Color.red : Color.gray.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Play button
                Button(action: {
                    // Add play functionality here
                }) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Stop button
                Button(action: {
                    // Add stop functionality here
                    isRecording = false
                }) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 20))
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .foregroundColor(.black)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Volume slider
                Slider(value: $volume, in: 0...1)
                    .frame(width: 100)
            }
            .padding(.horizontal, 20)
        }
        .padding()
        .background(Color.white)
        .frame(minWidth: 300, minHeight: 400)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TP7View()
    }
}
