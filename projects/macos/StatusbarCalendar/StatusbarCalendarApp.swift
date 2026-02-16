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
    @State private var holidayService = HolidayService()
    
    init() {
        print("🚀 StatusbarCalendar App launching...")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("📍 LSUIElement: \(Bundle.main.infoDictionary?["LSUIElement"] as? Bool ?? false)")
    }
    
    var body: some Scene {
        MenuBarExtra("日历", systemImage: "calendar") {
            MenuBarView(clockManager: clockManager, calendarManager: calendarManager)
                .frame(width: 380)
                .onAppear {
                    print("🎯 日历面板显示")
                    calendarManager.setHolidayService(holidayService)
                }
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(clockManager: clockManager)
        }
    }
}
