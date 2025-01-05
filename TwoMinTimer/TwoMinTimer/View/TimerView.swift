//
//  TimerView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var timerManager: TimerManager
    private let feedback = UINotificationFeedbackGenerator()
    
    var body: some View {
        ZStack {
            Text(timeString)
                .font(.system(size: 96, weight: .medium, design: .serif))
                .italic()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            VStack {
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "play.circle")
                        .symbolEffect(.pulse)
                    Text("Tap to start / stop")
                        .font(.system(size: 14, design: .serif))
                }
                .opacity(timerManager.isTimerRunning || timerManager.timeRemaining == 0 ? 0 : 1)
                .animation(.easeInOut(duration: 0.5), value: timerManager.isTimerRunning)
                .padding(.bottom, 75)
            }
            
            Color(.black)
                .opacity(calculateOpacity())
                .animation(
                    .interpolatingSpring(
                        duration: 1,
                        bounce: 0
                    ),
                    value: timerManager.timeRemaining
                )
                .animation(.easeOut(duration: 0.5), value: timerManager.isCompleted)
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            timerManager.toggleTimer()
        }
        .onLongPressGesture(minimumDuration: 0.75) {
            withAnimation {
                feedback.notificationOccurred(.error)
                timerManager.resetTimer()
            }
        }
        .ignoresSafeArea()
    }
    
    private var timeString: String {
        let minutes = Int(timerManager.timeRemaining) / 60
        let seconds = Int(timerManager.timeRemaining) % 60
        return String(format: "%02d’ %02d”", minutes, seconds)
    }
    
    private func calculateOpacity() -> Double {
        let progress = Double(timerManager.timeRemaining) / 120.0
        return 0.7 * (1 - progress)
    }
}
