import XCTest
@testable import StatusbarCalendar

@MainActor
final class ClockManagerTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "ClockManagerTests_\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testToggleShowSecondsPersists() {
        var options = DisplayOptions()
        options.showSeconds = false
        defaults.displayOptions = options

        let manager = ClockManager(userDefaults: defaults, shouldStartTimer: false)
        XCTAssertFalse(manager.displayOptions.showSeconds)

        manager.toggleShowSeconds()
        XCTAssertTrue(manager.displayOptions.showSeconds)
        XCTAssertTrue(defaults.displayOptions.showSeconds)
    }

    func testToggleTimeFormatPersists() {
        var options = DisplayOptions()
        options.timeFormat = .twentyFourHour
        defaults.displayOptions = options

        let manager = ClockManager(userDefaults: defaults, shouldStartTimer: false)
        XCTAssertEqual(manager.displayOptions.timeFormat, .twentyFourHour)

        manager.toggleTimeFormat()
        XCTAssertEqual(manager.displayOptions.timeFormat, .twelveHour)
        XCTAssertEqual(defaults.displayOptions.timeFormat, .twelveHour)
    }

    func testCurrentTimeStringIsNotEmpty() {
        let manager = ClockManager(userDefaults: defaults, shouldStartTimer: false)
        XCTAssertFalse(manager.currentTimeString.isEmpty)
    }
}
