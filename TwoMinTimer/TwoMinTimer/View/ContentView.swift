//
//  ContentView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @State private var showingSheet = false
    
    var body: some View {
        ZStack {
            if !timerManager.isCompleted {
                TimerView(timerManager: timerManager)
                    .transition(.asymmetric(
                        insertion: .opacity.animation(.easeInOut(duration: 1).delay(1)),
                        removal: .opacity.animation(.easeInOut(duration: 1))
                    ))
            } else {
                StopWatchView(timerManager: timerManager)
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
                                        showingSheet = true
                                    }
                                }
                }
        )
        .sheet(isPresented: $showingSheet) {
            NavigationStack {
                SheetView(timerManager: timerManager)
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    ContentView()
}
