//
//  ContentView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerManager: TimerManager
    
    var body: some View {
        ZStack {
            if !timerManager.isCompleted {
                TimerView()
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: 1).delay(1)),
                        removal: .opacity.animation(.easeInOut(duration: 1))
                    ))
            } else {
                StopWatchView()
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: 1).delay(1)),
                        removal: .opacity.animation(.easeInOut(duration: 1))
                    ))
            }
        }
        .frame(maxWidth: .infinity)
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height < -50 {
                        Task { @MainActor in
                            timerManager.showingSheet = true
                        }
                    }
                }
        )
        .sheet(isPresented: $timerManager.showingSheet) {
            NavigationStack {
                SheetView()
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerManager())
}
