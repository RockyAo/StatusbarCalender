import Foundation

/// 法定节假日 / 调休补班数据库（内置 JSON，可随年份自行更新）
final class HolidayDatabase {

    static let shared = HolidayDatabase()

    /// "2026-10-01" -> .statutoryOff / .swappedWorkday
    private var entries: [String: DayInfo.Kind] = [:]

    private init() {
        guard let url = Bundle.main.url(forResource: "holidays", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return }

        for (key, value) in json {
            guard key.count == 4, let year = Int(key),
                  let dict = value as? [String: [String]] else { continue }
            for mmdd in dict["holidays"] ?? [] {
                entries["\(year)-\(mmdd)"] = .statutoryOff
            }
            for mmdd in dict["workdays"] ?? [] {
                entries["\(year)-\(mmdd)"] = .swappedWorkday
            }
        }
    }

    func kind(of date: Date) -> DayInfo.Kind {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = c.year, let month = c.month, let day = c.day else { return .normal }
        return entries[String(format: "%d-%02d-%02d", year, month, day)] ?? .normal
    }

    /// 该月第一个法定假日名（用于月份标题旁的提示，可扩展）
    func isStatutoryOff(_ date: Date) -> Bool {
        kind(of: date) == .statutoryOff
    }
}
