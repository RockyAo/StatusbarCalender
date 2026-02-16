//
//  StatusbarCalendarApp.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

@main
struct StatusbarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var clockManager = ClockManager()
    @State private var calendarManager = CalendarManager()
    @State private var holidayService = HolidayService()
    @State private var menuBarManager = MenuBarManager()
    @State private var hasLaunched = false
    
    init() {
        print("🚀 StatusbarCalendar App launching...")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
        print("📍 LSUIElement: \(Bundle.main.infoDictionary?["LSUIElement"] as? Bool ?? false)")
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                clockManager: clockManager,
                calendarManager: calendarManager,
                holidayService: holidayService
            )
            .frame(width: 380)
            .onAppear {
                print("🎯 日历面板显示")
                calendarManager.setHolidayService(holidayService)
                
                // 设置 MenuBarManager
                appDelegate.menuBarManager = menuBarManager
                menuBarManager.setup()
                
                // 同步触发模式
                menuBarManager.triggerMode = clockManager.displayOptions.triggerMode
                
                // 每次打开 app 时加载当前年份数据
                if !hasLaunched {
                    hasLaunched = true
                    Task {
                        await holidayService.checkAndSyncOnAppLaunch()
                    }
                }
            }
            .onChange(of: clockManager.displayOptions.triggerMode) { _, newMode in
                menuBarManager.triggerMode = newMode
                print("📍 触发模式已更改为: \(newMode.displayName)")
            }
        } label: {
            Text(clockManager.currentTimeString)
                .fontDesign(.monospaced)
        }
        .menuBarExtraStyle(.window)
        
        Settings {
            SettingsView(clockManager: clockManager)
        }
    }
}
