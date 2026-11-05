import AppKit
import Combine
import SwiftUI

/// 菜单栏图标 + 弹窗宿主：NSStatusItem + NSPopover（比 MenuBarExtra 在各系统版本上更可靠）
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    private let app = AppState.shared
    private var statusItem: NSStatusItem?
    private let popover = NSPopover()
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 持有状态项本身即可保活；显式禁用自动终止双保险
        ProcessInfo.processInfo.disableAutomaticTermination("statusbar-item")
        NSApp.setActivationPolicy(.accessory)

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        // 图标 + 文字：即使文字渲染异常，日历图标也能兜底显示
        if let button = item.button {
            if let symbol = NSImage(
                systemSymbolName: "calendar",
                accessibilityDescription: "日历"
            ) {
                symbol.isTemplate = true
                button.image = symbol
            }
            button.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
            button.title = app.statusText
            button.target = self
            button.action = #selector(togglePopover(_:))
        }
        item.isVisible = true

        // 诊断日志（Xcode 控制台可见）
        print("[SBC] didFinishLaunching: statusText=\(app.statusText) button=\(String(describing: statusItem?.button))")

        popover.behavior = .transient   // 点击外部自动关闭
        popover.animates = true
        let host = NSHostingController(rootView: CalendarPopoverView().environmentObject(app))
        host.sizingOptions = .preferredContentSize   // 弹窗尺寸跟随 SwiftUI 内容
        popover.contentViewController = host

        app.$statusText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.statusItem?.button?.title = text
            }
            .store(in: &cancellables)

        // 加入 GUI 会话，确保状态项立即渲染
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            app.refreshStatusText()
            popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey()
        }
    }
}
