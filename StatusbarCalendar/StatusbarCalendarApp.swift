import SwiftUI

/// 菜单栏日历：NSStatusItem + NSPopover 承载 SwiftUI 面板（见 AppDelegate）
@main
struct StatusbarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        // 菜单栏应用无主窗口；占位 Scene 仅为满足 SwiftUI App 生命周期
        Settings { EmptyView() }
    }
}
