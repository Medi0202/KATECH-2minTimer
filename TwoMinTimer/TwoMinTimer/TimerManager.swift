//
//  TimerManager.swift
//  TwoMinTimer
//
//  Created by Jae Ho Yoon on 1/5/25.
//

import SwiftUI

class TimerManager: ObservableObject {
    @Published var timeRemaining: Int = 120
    @Published var isTimerRunning = false
    @Published var startTime: Date?
    @Published var isCompleted = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var pausedTime: TimeInterval = 0
    @Published var showingSheet = false
    @Published var showingAlert = false
    
    private var timer: Timer?
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private let feedback = UINotificationFeedbackGenerator()
    
    @AppStorage("totalTasks") private var totalTasks: Int = 0
    @AppStorage("totalFocusedTime") private var totalFocusedTime: TimeInterval = 0
    @AppStorage("recentSessions") private var recentSessionsData: Data = Data()

    private var backgroundStartTime: Date?
    
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
            backgroundStartTime = Date()
        } else {
            backgroundStartTime = Date()
        }
        
        registerBackgroundTask()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            }
            
            if self.timeRemaining == 0 {
                self.timerCompleted()
            }
        }
        
        scheduleNotification()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        endBackgroundTask()
    }
    
    private func timerCompleted() {
        isTimerRunning = false
        isCompleted = true
        stopTimer()
        
        feedback.notificationOccurred(.success)
        
        startTime = Date().addingTimeInterval(-120)
        startStopwatch()
    }
    
    func resetTimer() {
        stopTimer()
        timeRemaining = 120
        isTimerRunning = false
        startTime = nil
        isCompleted = false
        elapsedTime = 0
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["timerComplete"])
    }
    
    private func startStopwatch() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime) + 120
        }
    }
    
    // MARK: - Notification Controls
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
        }
    }

    private func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        // 25초 후에 자동으로 백그라운드 태스크를 종료하도록 설정
        DispatchQueue.main.asyncAfter(deadline: .now() + 25) { [weak self] in
            self?.endBackgroundTask()
        }
    }
    
    private func endBackgroundTask() {
        if backgroundTask != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            backgroundStartTime = nil
        }
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "2-Minute Timer Complete"
        content.body = "Task finished? Awesome!\nStill working? Stay in the flow!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: Double(timeRemaining), repeats: false)
        let request = UNNotificationRequest(identifier: "timerComplete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
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
    
    func pauseStopwatch() {
        timer?.invalidate()
        timer = nil
        pausedTime = elapsedTime
    }
    
    func resumeStopwatch() {
        startStopwatch()
    }
    
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
}
