//
//  SettingsWindow.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI
import AppKit

/// 设置窗口管理类
@MainActor
class SettingsWindow {
    private var window: NSWindow?
    private var windowDelegate: WindowDelegate?
    
    func show(clockManager: ClockManager) {
        print("📍 准备显示设置窗口")
        print("当前激活策略：\(NSApp.activationPolicy().rawValue) (0=regular, 1=accessory, 2=prohibited)")
        
        // 如果窗口已存在，直接显示
        if let existingWindow = window {
            print("♻️ 设置窗口已存在，复用")
            NSApp.setActivationPolicy(.regular)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                NSApp.activate(ignoringOtherApps: true)
                existingWindow.makeKeyAndOrderFront(nil)
                print("✅ 已激活已有窗口")
            }
            return
        }
        
        print("📍 切换为常规应用模式（显示 Dock 图标）")
        NSApp.setActivationPolicy(.regular)
        print("当前激活策略：\(NSApp.activationPolicy().rawValue)")
        
        // 延迟激活，确保策略切换生效
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            print("📍 激活应用")
            NSApp.activate(ignoringOtherApps: true)
            print("应用已激活状态：\(NSApp.isActive)")
            
            print("📍 创建新的设置窗口")
            self?.createAndShowWindow(clockManager: clockManager)
        }
    }
    
    private func createAndShowWindow(clockManager: ClockManager) {
        // 创建新窗口
        let settingsView = SettingsView(clockManager: clockManager)
        let hostingController = NSHostingController(rootView: settingsView)
        
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 450, height: 550),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        newWindow.title = "StatusbarCalendar 设置"
        newWindow.contentViewController = hostingController
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        
        // 设置窗口属性
        newWindow.level = .normal
        newWindow.collectionBehavior = [.canJoinAllSpaces]
        newWindow.isOpaque = true
        newWindow.backgroundColor = .windowBackgroundColor
        newWindow.hasShadow = true
        
        // 保持 delegate 的强引用
        let delegate = WindowDelegate { [weak self] in
            self?.onWindowClosed()
        }
        newWindow.delegate = delegate
        self.windowDelegate = delegate
        
        self.window = newWindow
        
        // 显示窗口
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
        
        print("📍 设置窗口已创建并显示")
        print("窗口可见：\(newWindow.isVisible)")
        print("窗口 key：\(newWindow.isKeyWindow)")
        print("✅ 设置窗口显示完成")
    }
    
    private func onWindowClosed() {
        print("📍 设置窗口已关闭，准备恢复为状态栏应用")
        
        // 延迟一下再切换，确保窗口关闭动画完成
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("🧹 恢复为辅助应用模式（隐藏 Dock 图标）")
            NSApp.setActivationPolicy(.accessory)
            print("✅ 已恢复为辅助应用模式")
        }
    }
}

// MARK: - Window Delegate

@MainActor
private class WindowDelegate: NSObject, NSWindowDelegate {
    private let onClose: () -> Void
    
    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
        super.init()
    }
    
    func windowWillClose(_ notification: Notification) {
        onClose()
    }
}
