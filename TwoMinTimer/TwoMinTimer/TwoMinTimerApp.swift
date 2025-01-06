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
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
