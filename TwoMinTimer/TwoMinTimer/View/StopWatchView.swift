//
//  StopWatchView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI
import Lottie

struct StopWatchView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var showingAlert = false
    @State private var showingSheet = false
    @State private var opacity: Double = 0.6
    
    var body: some View {
        ZStack {
            VStack(spacing: 32) {
                VStack(spacing: 16) {
                    LottieView(animation: .named("focused"))
                        .looping()
                        .resizable()
                        .scaledToFit()
                        .padding(.horizontal, 54)
                    
                    Text("You've been focused for")
                        .font(.system(size: 14, design: .serif))
                    
                    Text(formatElapsedTime(timerManager.elapsedTime))
                        .font(.system(size: 48, design: .serif))
                        .italic()
                        .padding(.vertical, -8)
                }
                
                Button {
                    showingAlert = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "stop.circle")
                        Text("Finish Focus")
                            .font(.system(size: 14, design: .serif))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .overlay {
                        RoundedRectangle(cornerRadius: 40)
                            .strokeBorder(.primary)
                    }
                    .foregroundStyle(.primary)
                }
                .buttonStyle(.plain)
                .alert("Save Focus Session", isPresented: $showingAlert) {
                    Button("Yes") {
                        withAnimation {
                            timerManager.saveFocusSession()
                        }
                    }
                    .keyboardShortcut(.defaultAction)
                    
                    Button("Discard", role: .destructive) {
                        withAnimation {
                            timerManager.resetTimer()
                        }
                    }
                    
                    Button("Not Yet", role: .cancel) { }
                } message: {
                    Text("Were you able to stay focused?")
                }
            }
            
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "arrow.up.circle")
                            .symbolEffect(.wiggle, options: .nonRepeating)
                    } else {
                        Image(systemName: "arrow.up.circle")
                    }
                    Text("Swipe up for detail")
                        .font(.system(size: 14, design: .serif))
                }
                .foregroundStyle(.secondary)
                .opacity(0.7)
                .padding(.bottom, 75)
            }
        }
        .ignoresSafeArea()
    }
    
    private func formatElapsedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
}
