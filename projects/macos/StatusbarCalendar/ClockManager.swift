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
    var showSeconds: Bool = true {
        didSet {
            updateTimeString()
            restartTimer()
        }
    }
    
    var currentTimeString: String = ""
    
    private let dateFormatter: DateFormatter
    private var timerSource: DispatchSourceTimer?
    
    init() {
        self.dateFormatter = DateFormatter()
        updateDateFormat()
        updateTimeString()
        startTimer()
    }
    
    // MARK: - Public Methods
    
    func toggleShowSeconds() {
        showSeconds.toggle()
        updateDateFormat()
        updateTimeString()
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
