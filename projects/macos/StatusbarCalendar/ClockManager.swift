//
//  ClockManager.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation
import Observation

@Observable
final class ClockManager {
    var showSeconds: Bool = true {
        didSet {
            updateTimeString()
        }
    }
    
    var currentTimeString: String = ""
    
    private var timer: Timer?
    private let dateFormatter: DateFormatter
    
    init() {
        self.dateFormatter = DateFormatter()
        updateDateFormat()
        updateTimeString()
        startTimer()
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: - Public Methods
    
    func toggleShowSeconds() {
        showSeconds.toggle()
        updateDateFormat()
        updateTimeString()
        restartTimer()
    }
    
    // MARK: - Private Methods
    
    private func updateDateFormat() {
        if showSeconds {
            dateFormatter.dateFormat = "HH:mm:ss"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
    }
    
    private func updateTimeString() {
        currentTimeString = dateFormatter.string(from: Date())
    }
    
    private func startTimer() {
        let interval: TimeInterval = showSeconds ? 1.0 : 60.0
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.updateTimeString()
        }
        // 确保 timer 在 common run loop mode 中运行
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartTimer() {
        stopTimer()
        startTimer()
    }
}
