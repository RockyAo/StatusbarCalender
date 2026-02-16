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
    @State private var hasLaunched = false
    
    init() {
        print("🚀 StatusbarCalendar App launching...")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("📍 LSUIElement: \(Bundle.main.infoDictionary?["LSUIElement"] as? Bool ?? false)")
    }
    
    var body: some Scene {
        MenuBarExtra("日历", systemImage: "calendar") {
            MenuBarView(
                clockManager: clockManager,
                calendarManager: calendarManager,
                holidayService: holidayService
            )
            .frame(width: 380)
            .onAppear {
                print("🎯 日历面板显示")
                calendarManager.setHolidayService(holidayService)
                
                // 每次打开 app 时加载当前年份数据
                if !hasLaunched {
                    hasLaunched = true
                    Task {
                        await holidayService.checkAndSyncOnAppLaunch()
                    }
                }
            }
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(clockManager: clockManager)
        }
    }
}
