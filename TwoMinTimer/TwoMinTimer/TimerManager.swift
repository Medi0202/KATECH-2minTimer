//
//  TimerManager.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI
import Combine

class TimerManager: ObservableObject {
    static let defaultTimerDuration: Int = 120

    @Published var timeRemaining: Int = defaultTimerDuration
    @Published var isTimerRunning = false
    @Published var startTime: Date?
    @Published var isCompleted = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var pausedTime: TimeInterval = 0
    @Published var showingSheet = false
    @Published var showingAlert = false
    @Published var pausedElapsedTime: TimeInterval = 0
    
    private var timerCancellable: AnyCancellable?
    private let feedback = UINotificationFeedbackGenerator()
    
    @AppStorage("totalTasks") private var totalTasks: Int = 0
    @AppStorage("totalFocusedTime") private var totalFocusedTime: TimeInterval = 0
    @AppStorage("recentSessions") private var recentSessionsData: Data = Data()
    @AppStorage("lastStartTime") private var lastStartTimeInterval: Double?
    
    init() {
        setupNotifications()
    }
    
    // MARK: - Timer Controls
    func toggleTimer() {
        isTimerRunning.toggle()
        
        if isTimerRunning {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        if startTime == nil {
            startTime = Date()
            lastStartTime = startTime
        } else {
            startTime = Date().addingTimeInterval(-pausedElapsedTime)
            lastStartTime = startTime
        }
        
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let startTime = self.startTime {
                    let elapsed = Int(Date().timeIntervalSince(startTime))
                    self.timeRemaining = max(Self.defaultTimerDuration - elapsed, 0)
                    
                    if self.timeRemaining == 0 {
                        self.timerCompleted()
                    }
                }
            }
        
        removeScheduledNotification()
        scheduleNotification(with: TimeInterval(timeRemaining))
    }
    
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
        
        if let startTime = startTime {
            pausedElapsedTime = Date().timeIntervalSince(startTime)
        }
        
        removeScheduledNotification()
    }
    
    private func timerCompleted() {
        isTimerRunning = false
        isCompleted = true
        stopTimer()
        
        feedback.notificationOccurred(.success)
        
        if let savedStartTime = lastStartTime {
            startTime = savedStartTime
        } else {
            startTime = Date().addingTimeInterval(-120)
        }
        startStopwatch()
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = 120
        isTimerRunning = false
        startTime = nil
        lastStartTime = nil
        isCompleted = false
        elapsedTime = 0
        
        removeScheduledNotification()
    }
    
    // MARK: - Stopwatch Controls
    private func startStopwatch() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, let startTime = self.lastStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
    }
    
    func pauseStopwatch() {
        timerCancellable?.cancel()
        timerCancellable = nil
        pausedTime = elapsedTime
    }
    
    func resumeStopwatch() {
        startStopwatch()
    }
    
    // MARK: - Notification Controls
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission request error: \(error)")
                return
            }
            
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    private func scheduleNotification(with timeInterval: TimeInterval) {
        print("Scheduling notification in: \(timeInterval) seconds")
        
        let content = UNMutableNotificationContent()
        content.title = "2-Minute Timer Complete"
        content.body = "Task finished? Awesome!\nStill working? Stay in the flow!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
    
    private func removeScheduledNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerComplete"])
    }
    
    // MARK: - Storing focus sessions
    private struct FocusSession: Codable {
        let timestamp: Date
        let duration: TimeInterval
    }
    
    private var recentSessions: [FocusSession] {
        get {
            (try? JSONDecoder().decode([FocusSession].self, from: recentSessionsData)) ?? []
        }
        set {
            recentSessionsData = (try? JSONEncoder().encode(newValue)) ?? Data()
        }
    }
    
    private func cleanOldData() {
        let twentyFourHoursAgo = Date().addingTimeInterval(-24 * 60 * 60)
        recentSessions = recentSessions.filter { $0.timestamp > twentyFourHoursAgo }
    }
    
    func saveFocusSession() {
        totalTasks += 1
        totalFocusedTime += elapsedTime
        
        let newSession = FocusSession(timestamp: Date(), duration: elapsedTime)
        recentSessions.append(newSession)
        cleanOldData()
        
        resetTimer()
    }
    
    func getStatisticsData() -> (lastDayTasks: Int, lastDayTime: TimeInterval, totalTasks: Int, totalTime: TimeInterval) {
        cleanOldData()
        let lastDayTime = recentSessions.reduce(0) { $0 + $1.duration }
        return (recentSessions.count, lastDayTime, totalTasks, totalFocusedTime)
    }
    
    // MARK: - Shared
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else {
            return String(format: "%dm %ds", minutes, seconds)
        }
    }
    
    private var lastStartTime: Date? {
        get {
            if let timeInterval = lastStartTimeInterval {
                return Date(timeIntervalSince1970: timeInterval)
            }
            return nil
        }
        set {
            lastStartTimeInterval = newValue?.timeIntervalSince1970
        }
    }
}
