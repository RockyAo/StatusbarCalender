//
//  ClockManager.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation
import Observation

@Observable
@MainActor
final class ClockManager {
    var displayOptions: DisplayOptions {
        didSet {
            userDefaults.displayOptions = displayOptions
            updateTimeString()
            restartTimer()
        }
    }
    
    var currentTimeString: String = ""
    
    private var timerSource: DispatchSourceTimer?
    private let lunarCalendar: LunarCalendar
    private let calendar: Calendar
    private let userDefaults: UserDefaults
    
    init(
        userDefaults: UserDefaults = .standard,
        calendar: Calendar = .current,
        lunarCalendar: LunarCalendar = LunarCalendar(),
        shouldStartTimer: Bool = true
    ) {
        self.userDefaults = userDefaults
        self.calendar = calendar
        self.lunarCalendar = lunarCalendar
        // 从 UserDefaults 加载显示选项
        self.displayOptions = userDefaults.displayOptions
        updateTimeString()
        if shouldStartTimer {
            startTimer()
        }
    }
    
    // MARK: - Public Methods
    
    /// 切换显示秒
    func toggleShowSeconds() {
        displayOptions.showSeconds.toggle()
    }
    
    /// 切换时间格式
    func toggleTimeFormat() {
        displayOptions.timeFormat = (displayOptions.timeFormat == .twentyFourHour) ? .twelveHour : .twentyFourHour
    }
    
    // MARK: - Private Methods
    
    private func updateTimeString() {
        let now = Date()
        let lunarText = lunarCalendar.fullLunarInfo(from: now)
        currentTimeString = displayOptions.generateStatusBarText(
            date: now,
            lunarText: lunarText,
            calendar: calendar
        )
    }
    
    private func startTimer() {
        let interval: TimeInterval = displayOptions.showSeconds ? 1.0 : 60.0
        
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.updateTimeString()
        }
        timer.resume()
        
        self.timerSource = timer
    }
    
    private func stopTimer() {
        timerSource?.cancel()
        timerSource = nil
    }
    
    private func restartTimer() {
        stopTimer()
        startTimer()
    }
}

