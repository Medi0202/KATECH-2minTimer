//
//  SheetView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI

struct SheetView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var stats: (lastDayTasks: Int, lastDayTime: TimeInterval, totalTasks: Int, totalTime: TimeInterval)?
    
    var body: some View {
        VStack {
            if let stats = stats {
                List {
                    Section(header: Text("Last 24 hours")) {
                        HStack {
                            Text("Tasks Completed")
                            Spacer()
                            Text("\(stats.lastDayTasks)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Time Focused")
                            Spacer()
                            Text(formatTime(stats.lastDayTime))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section(header: Text("Your Achievements")) {
                        HStack {
                            Text("Tasks")
                            Spacer()
                            Text("\(stats.totalTasks)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Time Focused")
                            Spacer()
                            Text(formatTime(stats.totalTime))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            stats = timerManager.getStatisticsData()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
}
