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
    @State private var showSettings = false
    @State private var settingsWindowDelegate: SettingsWindowDelegate?
    
    init() {
        print("🚀 StatusbarCalendar App launching...")
        print("📍 Bundle ID: \(Bundle.main.bundleIdentifier ?? "unknown")")
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(
                clockManager: clockManager,
                calendarManager: calendarManager,
                holidayService: holidayService,
                showSettings: $showSettings
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
            .onChange(of: showSettings) { _, isShowing in
                if isShowing {
                    print("📍 设置窗口已请求打开")
                    NSApp.setActivationPolicy(.regular)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NSApp.activate(ignoringOtherApps: true)
                        // 打开设置窗口
                        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "settings-window" }) {
                            window.makeKeyAndOrderFront(nil)
                        } else {
                            self.openSettingsWindow()
                        }
                    }
                } else {
                    print("📍 设置窗口已关闭")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
            }
        } label: {
            Text(clockManager.currentTimeString)
                .fontDesign(.monospaced)
        }
        .menuBarExtraStyle(.window)
    }
    
    private func openSettingsWindow() {
        let settingsView = SettingsView(clockManager: clockManager)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "StatusbarCalendar 设置"
        window.identifier = NSUserInterfaceItemIdentifier("settings-window")
        window.contentViewController = hostingController
        window.center()
        window.isReleasedWhenClosed = false
        
        // 创建窗口代理来监听关闭事件
        let delegate = SettingsWindowDelegate { [self] in
            showSettings = false
        }
        window.delegate = delegate
        settingsWindowDelegate = delegate
        
        window.makeKeyAndOrderFront(nil)
    }
}

// MARK: - Settings Window Delegate

class SettingsWindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
