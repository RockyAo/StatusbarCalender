import XCTest
@testable import StatusbarCalendar

final class LunarCalendarTests: XCTestCase {
    func testLunarDateStringForFirstDayShowsMonth() {
        guard let date = findDate(withLunarDay: 1) else {
            XCTFail("No lunar day 1 found in search range")
            return
        }

        let calendar = LunarCalendar()
        let text = calendar.lunarDateString(from: date)

        XCTAssertTrue(text.contains("月"))
    }

    func testLunarDateStringForCommonDays() {
        guard let day10 = findDate(withLunarDay: 10),
              let day20 = findDate(withLunarDay: 20),
              let day30 = findDate(withLunarDay: 30) else {
            XCTFail("No matching lunar days found in search range")
            return
        }

        let calendar = LunarCalendar()

        XCTAssertEqual(calendar.lunarDateString(from: day10), "初十")
        XCTAssertEqual(calendar.lunarDateString(from: day20), "二十")
        XCTAssertEqual(calendar.lunarDateString(from: day30), "三十")
    }

    private func findDate(withLunarDay target: Int) -> Date? {
        let chineseCalendar = Calendar(identifier: .chinese)
        var date = Date()

        for _ in 0..<400 {
            let lunarDay = chineseCalendar.component(.day, from: date)
            if lunarDay == target {
                return date
            }
            date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        }

        return nil
    }
}
