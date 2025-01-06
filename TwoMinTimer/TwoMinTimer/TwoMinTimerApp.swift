//
//  TwoMinTimerApp.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/4/25.
//

import SwiftUI

@main
struct TwoMinTimerApp: App {
    @StateObject var timerManager = TimerManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
        }
    }
}
