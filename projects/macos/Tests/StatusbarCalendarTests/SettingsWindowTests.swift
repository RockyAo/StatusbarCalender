import XCTest
import AppKit
@testable import StatusbarCalendar

@MainActor
final class SettingsWindowTests: XCTestCase {
    func testShowDoesNotCrash() async {
        let suiteName = "SettingsWindowTests_\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)

        let manager = ClockManager(userDefaults: defaults, shouldStartTimer: false)
        let windowManager = SettingsWindow()

        windowManager.show(clockManager: manager)
        try? await Task.sleep(nanoseconds: 400_000_000)

        for window in NSApp.windows {
            window.close()
        }
    }
}
