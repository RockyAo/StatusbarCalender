//
//  MenuBarManager.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import AppKit
import Observation

/// 管理菜单栏项目的悬停和点击行为
@Observable
@MainActor
final class MenuBarManager {
    private var eventMonitor: Any?
    private var localEventMonitor: Any?
    private var hoverTimer: Timer?
    private var lastKnownStatusBarRect: NSRect?
    private let hoverDelay: TimeInterval = 0.3
    private var isHovering = false
    private var lastTriggerTime: Date = .distantPast
    private let cooldownInterval: TimeInterval = 3.0 // 冷却时间3秒
    
    var triggerMode: TriggerMode = .click {
        didSet {
            updateEventMonitoring()
        }
    }
    
    // MARK: - Public Methods
    
    func setup() {
        updateEventMonitoring()
    }
    
    func cleanup() {
        stopEventMonitoring()
        hoverTimer?.invalidate()
        hoverTimer = nil
    }
    
    // 更新状态栏按钮的位置（由外部调用）
    func updateStatusBarRect(_ rect: NSRect) {
        lastKnownStatusBarRect = rect
    }
    
    // MARK: - Private Methods
    
    private func updateEventMonitoring() {
        stopEventMonitoring()
        
        if triggerMode == .hover {
            startEventMonitoring()
        }
    }
    
    private func startEventMonitoring() {
        // 检查辅助功能权限
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️ 没有辅助功能权限，悬停功能无法使用")
            return
        }
        
        // 全局鼠标移动监听
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMoved()
        }
        
        // 本地鼠标移动监听
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.mouseMoved]) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }
        
        print("✅ 悬停模式事件监听已启动")
    }
    
    private func stopEventMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        hoverTimer?.invalidate()
        hoverTimer = nil
        isHovering = false
    }
    
    private func handleMouseMoved() {
        let mouseLocation = NSEvent.mouseLocation
        
        // 检查鼠标是否在菜单栏区域（屏幕顶部）
        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.frame
        let menuBarHeight: CGFloat = 24
        
        // 菜单栏完整区域
        let menuBarRect = NSRect(
            x: screenFrame.minX,
            y: screenFrame.maxY - menuBarHeight,
            width: screenFrame.width,
            height: menuBarHeight
        )
        
        // 状态栏通常在右侧，检查右侧200px区域
        let statusBarArea = NSRect(
            x: screenFrame.maxX - 200,
            y: menuBarRect.minY,
            width: 200,
            height: menuBarHeight
        )
        
        if statusBarArea.contains(mouseLocation) {
            scheduleHoverAction()
        } else {
            cancelHoverAction()
        }
    }
    
    private func scheduleHoverAction() {
        guard !isHovering else { return }
        
        // 检查冷却时间
        let timeSinceLastTrigger = Date().timeIntervalSince(lastTriggerTime)
        if timeSinceLastTrigger < cooldownInterval {
            return
        }
        
        // 如果已经有计时器在运行，不重复创建
        if hoverTimer == nil {
            hoverTimer = Timer.scheduledTimer(withTimeInterval: hoverDelay, repeats: false) { [weak self] _ in
                self?.triggerHover()
            }
        }
    }
    
    private func cancelHoverAction() {
        hoverTimer?.invalidate()
        hoverTimer = nil
        isHovering = false
    }
    
    private func triggerHover() {
        isHovering = true
        hoverTimer = nil
        lastTriggerTime = Date()
        
        print("🎯 悬停触发 - 模拟点击")
        
        // 获取当前鼠标位置
        let mouseLocation = NSEvent.mouseLocation
        let screenPoint = CGPoint(x: mouseLocation.x, y: mouseLocation.y)
        
        // 创建并发送鼠标点击事件
        guard let mouseDown = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseDown,
            mouseCursorPosition: screenPoint,
            mouseButton: .left
        ) else {
            print("❌ 无法创建鼠标按下事件")
            return
        }
        
        guard let mouseUp = CGEvent(
            mouseEventSource: nil,
            mouseType: .leftMouseUp,
            mouseCursorPosition: screenPoint,
            mouseButton: .left
        ) else {
            print("❌ 无法创建鼠标释放事件")
            return
        }
        
        // 发送事件
        mouseDown.post(tap: .cghidEventTap)
        
        // 短暂延迟后发送释放事件
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            mouseUp.post(tap: .cghidEventTap)
            print("✅ 鼠标点击事件已发送")
        }
        
        // 延迟重置悬停状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.isHovering = false
        }
    }
}

