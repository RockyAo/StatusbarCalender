import SwiftUI

/// 菜单栏日历：菜单栏实时日期 + 农历，点击弹出月历面板
@main
struct StatusbarCalendarApp: App {
    @StateObject private var app = AppState()

    var body: some Scene {
        MenuBarExtra {
            CalendarPopoverView()
                .environmentObject(app)
        } label: {
            Text(app.statusText)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(app)
        }
    }
}
