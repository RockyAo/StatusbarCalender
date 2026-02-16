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
    @State private var calendarManager = CalendarManager()
    
    init() {
        print("🚀 StatusbarCalendar App launching...")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("📍 LSUIElement: \(Bundle.main.infoDictionary?["LSUIElement"] as? Bool ?? false)")
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(clockManager: clockManager, calendarManager: calendarManager)
                .onAppear {
                    print("✅ MenuBarExtra content appeared")
                }
        } label: {
            Text(clockManager.currentTimeString)
                .font(.system(.body, design: .monospaced))
                .monospacedDigit()
                .onAppear {
                    print("✅ MenuBarExtra label appeared: \(clockManager.currentTimeString)")
                }
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(clockManager: clockManager)
        }
    }
}
