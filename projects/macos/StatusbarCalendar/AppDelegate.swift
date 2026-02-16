//
//  AppDelegate.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    let settingsWindow = SettingsWindow()
    
    private var hasRequestedPermission: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasRequestedAccessibilityPermission")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasRequestedAccessibilityPermission")
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ App 启动完成")
        
        // 延迟设置为辅助应用，确保 MenuBarExtra 已完全初始化
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("📍 延迟设置为辅助应用模式（无 Dock 图标）")
            NSApp.setActivationPolicy(.accessory)
            print("📍 已设置为辅助应用模式")
        }
        
        // 检查辅助功能权限（仅检查，不弹窗）
        checkAccessibilityPermission()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        menuBarManager?.cleanup()
    }
    
    // MARK: - Accessibility Permission
    
    private func checkAccessibilityPermission() {
        // 仅检查权限状态，不弹窗
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            print("✅ 已获得辅助功能权限")
        } else {
            print("⚠️ 未获得辅助功能权限（悬停功能需要此权限）")
        }
    }
    
    func requestAccessibilityPermissionIfNeeded() {
        // 如果已经请求过，不再重复请求
        if hasRequestedPermission {
            print("📍 已经请求过辅助功能权限，不再重复弹窗")
            return
        }
        
        // 检查当前是否已有辅助功能权限
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            print("✅ 已获得辅助功能权限")
            return
        }
        
        // 标记已请求
        hasRequestedPermission = true
        
        print("⚠️ 需要辅助功能权限以支持鼠标悬停功能")
        print("📍 请前往 系统设置 → 隐私与安全性 → 辅助功能 勾选本应用")
        
        // 显示自定义提示对话框
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let alert = NSAlert()
            alert.messageText = "需要辅助功能权限"
            alert.informativeText = "为了支持鼠标悬停触发面板功能，StatusbarCalendar 需要辅助功能权限。\n\n请点击打开系统设置，然后在「隐私与安全性」→「辅助功能」中勾选 StatusbarCalendar。\n\n授权后请重启应用以使权限生效。"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "打开系统设置")
            alert.addButton(withTitle: "稍后设置")
            
            let response = alert.runModal()
            if response == .alertFirstButtonReturn {
                // 打开系统设置的辅助功能页面
                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }
    
    // 重置权限请求标记（用于测试或让用户重新请求权限）
    func resetPermissionRequestFlag() {
        hasRequestedPermission = false
        print("🔄 已重置辅助功能权限请求标记")
    }
    
    // MARK: - Settings Window
    
    @MainActor
    func showSettings(clockManager: ClockManager) {
        settingsWindow.show(clockManager: clockManager)
    }
    
}
