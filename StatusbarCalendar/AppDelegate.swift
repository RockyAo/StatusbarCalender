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

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        item.button?.title = app.statusText
        item.button?.target = self
        item.button?.action = #selector(togglePopover(_:))
        statusItem = item

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
