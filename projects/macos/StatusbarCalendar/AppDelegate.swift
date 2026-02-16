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
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("✅ App 启动完成")
        
        // 提前请求辅助功能权限（用于悬停功能）
        requestAccessibilityPermission()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        menuBarManager?.cleanup()
    }
    
    // MARK: - Accessibility Permission
    
    private func requestAccessibilityPermission() {
        // 检查当前是否已有辅助功能权限（不使用系统提示以避免并发警告）
        let trusted = AXIsProcessTrusted()
        
        if trusted {
            print("✅ 已获得辅助功能权限")
        } else {
            print("⚠️ 需要辅助功能权限以支持鼠标悬停功能")
            print("📍 请前往 系统设置 → 隐私与安全性 → 辅助功能 勾选本应用")
            
            // 显示自定义提示对话框
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let alert = NSAlert()
                alert.messageText = "需要辅助功能权限"
                alert.informativeText = "为了支持鼠标悬停触发面板功能，StatusbarCalendar 需要辅助功能权限。\n\n请点击打开系统设置，然后在隐私与安全性辅助功能中勾选 StatusbarCalendar。"
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
    }
    
}
