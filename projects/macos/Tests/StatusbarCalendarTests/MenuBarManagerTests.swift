import XCTest
import AppKit
@testable import StatusbarCalendar

@MainActor
final class MenuBarManagerTests: XCTestCase {
    func testSetupAndCleanupInClickMode() {
        let manager = MenuBarManager()
        manager.triggerMode = .click
        manager.setup()
        manager.cleanup()
    }

    func testSetupAndCleanupInHoverMode() {
        let manager = MenuBarManager()
        manager.triggerMode = .hover
        manager.setup()
        manager.cleanup()
    }
}
