//
//  StopWatchView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI
import Lottie

struct StopWatchView: View {
    @EnvironmentObject var timerManager: TimerManager
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
                    
                    Text(timerManager.formatTime(timerManager.elapsedTime))
                        .font(.system(size: 48, design: .serif))
                        .italic()
                        .padding(.vertical, -8)
                }
                
                Button {
                    timerManager.showingAlert = true
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
                .alert("Save Focus Session", isPresented: $timerManager.showingAlert) {
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
                .opacity(!timerManager.isStopwatchRunning ? 0.7 : 0)
                .animation(.easeInOut, value: timerManager.isStopwatchRunning)
                .padding(.bottom, 75)
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            timerManager.toggleStopwatch()
        }
        .ignoresSafeArea()
    }
}
