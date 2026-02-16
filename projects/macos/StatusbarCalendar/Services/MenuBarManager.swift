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
    private var menuBarButtonFrame: NSRect?
    private let hoverDelay: TimeInterval = 0.3
    private var isHovering = false
    private var lastTriggerTime: Date = .distantPast
    private let cooldownInterval: TimeInterval = 3.0 // 冷却时间3秒
    private var frameUpdateTimer: Timer?
    
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
        stopFrameUpdateTimer()
        hoverTimer?.invalidate()
        hoverTimer = nil
    }
    
    // MARK: - Private Methods
    
    private func startFrameUpdateTimer() {
        // 立即执行一次
        updateMenuBarButtonFrame()
        
        // 定期更新按钮位置（因为状态栏项目位置可能会变化）
        frameUpdateTimer?.invalidate()
        frameUpdateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMenuBarButtonFrame()
        }
    }
    
    private func stopFrameUpdateTimer() {
        frameUpdateTimer?.invalidate()
        frameUpdateTimer = nil
    }
    
    private func updateMenuBarButtonFrame() {
        guard let screen = NSScreen.main else { return }
        
        // 使用 Accessibility API 查找状态栏按钮
        let systemWideElement = AXUIElementCreateSystemWide()
        var statusItems: CFTypeRef?
        
        // 获取菜单栏
        let result = AXUIElementCopyAttributeValue(systemWideElement, kAXMenuBarAttribute as CFString, &statusItems)
        
        if result == .success, let menuBar = statusItems {
            var children: CFTypeRef?
            let childrenResult = AXUIElementCopyAttributeValue(menuBar as! AXUIElement, kAXChildrenAttribute as CFString, &children)
            
            if childrenResult == .success, let items = children as? [AXUIElement] {
                let currentPID = ProcessInfo.processInfo.processIdentifier
                
                // 查找属于我们进程的状态栏项目
                for item in items {
                    var pid: pid_t = 0
                    let pidResult = AXUIElementGetPid(item, &pid)
                    
                    if pidResult == .success && pid == currentPID {
                        var position: CFTypeRef?
                        var size: CFTypeRef?
                        AXUIElementCopyAttributeValue(item, kAXPositionAttribute as CFString, &position)
                        AXUIElementCopyAttributeValue(item, kAXSizeAttribute as CFString, &size)
                        
                        if let position = position, let size = size {
                            var point = CGPoint.zero
                            var sizeValue = CGSize.zero
                            
                            AXValueGetValue(position as! AXValue, .cgPoint, &point)
                            AXValueGetValue(size as! AXValue, .cgSize, &sizeValue)
                            
                            // 转换坐标（Accessibility 使用屏幕坐标，Y轴向下）
                            let screenHeight = screen.frame.height
                            let adjustedY = screenHeight - point.y - sizeValue.height
                            
                            let frame = NSRect(
                                x: point.x,
                                y: adjustedY,
                                width: sizeValue.width,
                                height: sizeValue.height
                            )
                            
                            menuBarButtonFrame = frame
                            print("✅ 找到状态栏按钮位置: x=\(Int(frame.origin.x)), y=\(Int(frame.origin.y)), width=\(Int(frame.width)), height=\(Int(frame.height))")
                            return
                        }
                    }
                }
                
                print("⚠️ 未找到属于本应用的状态栏按钮")
            }
        }
    }
    
    private func updateEventMonitoring() {
        stopEventMonitoring()
        
        if triggerMode == .hover {
            startEventMonitoring()
            startFrameUpdateTimer()
        } else {
            stopFrameUpdateTimer()
        }
    }
    
    private func startEventMonitoring() {
        // 检查辅助功能权限
        let trusted = AXIsProcessTrusted()
        if !trusted {
            print("⚠️ 没有辅助功能权限，悬停功能无法使用")
            
            // 请求权限
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                appDelegate.requestAccessibilityPermissionIfNeeded()
            }
            return
        }
        
        print("✅ 辅助功能权限已授权")
        
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
        
        // 首先检查是否在菜单栏区域
        guard menuBarRect.contains(mouseLocation) else {
            cancelHoverAction()
            return
        }

        if isMouseOverOurStatusItem(mouseLocation: mouseLocation) {
            scheduleHoverAction()
            return
        }
        
        var isInButtonArea = false
        
        // 如果已经找到了按钮位置，使用精确检测
        if let buttonFrame = menuBarButtonFrame {
            // 扩展一点检测区域，让体验更好
            let expandedFrame = buttonFrame.insetBy(dx: -5, dy: -2)
            isInButtonArea = expandedFrame.contains(mouseLocation)
            
            if isInButtonArea {
                scheduleHoverAction()
            } else {
                cancelHoverAction()
            }
        } else {
            // 如果还没找到按钮位置，使用右侧区域作为后备方案
            // 扩大检测区域到 500px，因为状态栏图标可能在任意位置
            let statusBarArea = NSRect(
                x: screenFrame.maxX - 500,
                y: menuBarRect.minY,
                width: 500,
                height: menuBarHeight
            )
            
            isInButtonArea = statusBarArea.contains(mouseLocation)
            
            if isInButtonArea {
                scheduleHoverAction()
            } else {
                cancelHoverAction()
            }
        }
    }

    private func isMouseOverOurStatusItem(mouseLocation: NSPoint) -> Bool {
        guard let screen = screenContaining(point: mouseLocation) else { return false }

        let screenHeight = screen.frame.height
        let axPoint = CGPoint(x: mouseLocation.x, y: screenHeight - mouseLocation.y)

        let systemWideElement = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        let result = AXUIElementCopyElementAtPosition(systemWideElement, Float(axPoint.x), Float(axPoint.y), &element)

        guard result == .success, let hitElement = element else { return false }

        return elementBelongsToCurrentApp(hitElement)
    }

    private func elementBelongsToCurrentApp(_ element: AXUIElement) -> Bool {
        let currentPID = ProcessInfo.processInfo.processIdentifier
        var current: AXUIElement? = element

        for _ in 0..<6 {
            guard let target = current else { break }

            var pid: pid_t = 0
            if AXUIElementGetPid(target, &pid) == .success, pid == currentPID {
                return true
            }

            var parentRef: CFTypeRef?
            let parentResult = AXUIElementCopyAttributeValue(target, kAXParentAttribute as CFString, &parentRef)
            if parentResult == .success, let parentRef = parentRef {
                let parent = parentRef as! AXUIElement
                current = parent
            } else {
                break
            }
        }

        return false
    }

    private func screenContaining(point: NSPoint) -> NSScreen? {
        for screen in NSScreen.screens {
            if screen.frame.contains(point) {
                return screen
            }
        }
        return NSScreen.main
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
            print("⏰ 开始悬停计时 (延迟 \(hoverDelay) 秒)")
            hoverTimer = Timer.scheduledTimer(withTimeInterval: hoverDelay, repeats: false) { [weak self] _ in
                self?.triggerHover()
            }
        }
    }
    
    private func cancelHoverAction() {
        if hoverTimer != nil {
            hoverTimer?.invalidate()
            hoverTimer = nil
            isHovering = false
        }
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

