import XCTest
@testable import StatusbarCalendar

@MainActor
final class HolidayServiceTests: XCTestCase {
    override func setUp() {
        super.setUp()
        URLProtocolStub.reset()
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        super.tearDown()
    }

    func testEnsureYearLoadedFetchesAndCaches() async {
        let tempDir = TemporaryDirectory()
        let database = HolidayDatabase(baseDirectory: tempDir.url)
        let service = HolidayService(database: database)

        let payload = HolidayResponse(
            code: 200,
            data: [
                HolidayDay(date: "2026-02-16", days: 1, holiday: true, name: "Holiday"),
                HolidayDay(date: "2026-02-17", days: 0, holiday: false, name: "Work")
            ]
        )
        let data = try? JSONEncoder().encode(payload)
        URLProtocolStub.responseData = data
        URLProtocolStub.statusCode = 200

        await service.ensureYearLoaded(2026)

        XCTAssertEqual(service.getStatus(for: makeDate(2026, 2, 16)), .holiday)
        XCTAssertEqual(service.getStatus(for: makeDate(2026, 2, 17)), .workday)
        XCTAssertEqual(URLProtocolStub.requestCount, 1)

        await service.ensureYearLoaded(2026)
        XCTAssertEqual(URLProtocolStub.requestCount, 1)
    }

    func testEnsureYearLoadedHandlesHttpFailure() async {
        let tempDir = TemporaryDirectory()
        let database = HolidayDatabase(baseDirectory: tempDir.url)
        let service = HolidayService(database: database)

        URLProtocolStub.responseData = Data()
        URLProtocolStub.statusCode = 500

        await service.ensureYearLoaded(2026)

        XCTAssertEqual(service.getStatus(for: makeDate(2026, 2, 16)), .normal)
    }
}
