import Foundation
import XCTest

final class TemporaryDirectory {
    let url: URL

    init() {
        let base = FileManager.default.temporaryDirectory
        url = base.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }

    deinit {
        try? FileManager.default.removeItem(at: url)
    }
}

final class URLProtocolStub: URLProtocol {
    nonisolated(unsafe) static var responseData: Data?
    nonisolated(unsafe) static var statusCode: Int = 200
    nonisolated(unsafe) static var error: Error?
    nonisolated(unsafe) static var requestCount = 0

    static func reset() {
        responseData = nil
        statusCode = 200
        error = nil
        requestCount = 0
    }

    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.host == "date.appworlds.cn"
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requestCount += 1

        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let url = request.url ?? URL(string: "https://date.appworlds.cn")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: Self.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)

        if let data = Self.responseData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents()
    components.calendar = Calendar(identifier: .gregorian)
    components.timeZone = TimeZone.current
    components.year = year
    components.month = month
    components.day = day
    components.hour = 12
    components.minute = 0
    components.second = 0
    return components.date ?? Date()
}
