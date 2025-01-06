//
//  SheetView.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI

struct SheetView: View {
    @EnvironmentObject var timerManager: TimerManager
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
                            Text(timerManager.formatTime(stats.lastDayTime))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Section(header: Text("Your Achievements")) {
                        HStack {
                            Text("Tasks Completed")
                            Spacer()
                            Text("\(stats.totalTasks)")
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Text("Time Focused")
                            Spacer()
                            Text(timerManager.formatTime(stats.totalTime))
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
}
