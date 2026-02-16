//
//  StatusbarCalendarApp.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

@main
struct StatusbarCalendarApp: App {
    @State private var clockManager = ClockManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(clockManager: clockManager)
        } label: {
            Text(clockManager.currentTimeString)
                .monospacedDigit()
        }
    }
}
