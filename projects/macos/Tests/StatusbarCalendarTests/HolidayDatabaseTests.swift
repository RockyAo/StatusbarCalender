import XCTest
@testable import StatusbarCalendar

final class HolidayDatabaseTests: XCTestCase {
    func testSaveAndQueryHolidays() {
        let tempDir = TemporaryDirectory()
        let database = HolidayDatabase(baseDirectory: tempDir.url)

        let holidays = [
            HolidayDay(date: "2026-02-16", days: 1, holiday: true, name: "TestHoliday"),
            HolidayDay(date: "2026-02-17", days: 0, holiday: false, name: "Workday")
        ]

        database.saveHolidays(holidays, year: 2026)

        XCTAssertEqual(database.getHoliday(for: "2026-02-16"), .holiday)
        XCTAssertEqual(database.getHoliday(for: "2026-02-17"), .workday)

        let all = database.getAllHolidays()
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all["2026-02-16"]?.name, "TestHoliday")
    }

    func testUnknownDateReturnsNormal() {
        let tempDir = TemporaryDirectory()
        let database = HolidayDatabase(baseDirectory: tempDir.url)

        XCTAssertEqual(database.getHoliday(for: "2026-12-31"), .normal)
    }

    func testSaveEmptyListStillUpdatesMetadata() {
        let tempDir = TemporaryDirectory()
        let database = HolidayDatabase(baseDirectory: tempDir.url)

        database.saveHolidays([], year: 2030)

        XCTAssertEqual(database.getMetadata(key: "last_sync_year"), "2030")
        XCTAssertNotNil(database.getMetadata(key: "last_sync_date"))
    }
}
