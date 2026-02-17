import XCTest
@testable import StatusbarCalendar

@MainActor
final class CalendarManagerTests: XCTestCase {
    func testDaysInMonthIsSequential() {
        let manager = CalendarManager()
        manager.selectedMonth = makeDate(2026, 2, 15)

        let days = manager.daysInMonth()
        XCTAssertTrue((28...42).contains(days.count))

        let calendar = Calendar.current
        for index in 1..<days.count {
            let previous = days[index - 1].date
            let expected = calendar.date(byAdding: .day, value: 1, to: previous)
            XCTAssertNotNil(expected)
            XCTAssertTrue(calendar.isDate(days[index].date, inSameDayAs: expected!))
        }
    }

    func testLeapYearFebruaryHas29Days() {
        let manager = CalendarManager()
        manager.selectedMonth = makeDate(2024, 2, 15)

        let currentMonthDays = manager.daysInMonth().filter { $0.isCurrentMonth }
        XCTAssertEqual(currentMonthDays.count, 29)
    }

    func testGoToTodayUpdatesDates() {
        let manager = CalendarManager()
        manager.selectedMonth = makeDate(2000, 1, 1)
        manager.currentDate = makeDate(2000, 1, 1)

        manager.goToToday()

        let calendar = Calendar.current
        XCTAssertTrue(calendar.isDateInToday(manager.selectedMonth))
        XCTAssertTrue(calendar.isDateInToday(manager.currentDate))
    }
}
