import Foundation

/// 法定节假日 / 调休补班数据库
///
/// 数据分两层：
/// 1. 内置 JSON（随 app 分发，离线兜底）
/// 2. 远程 JSON（指向本仓库 holidays.json，经 jsDelivr CDN 拉取）
///    —— 更新放假安排只需 git push 该文件，已安装的 app 会自动拉取，无需发版
///
/// 合并策略：远程数据按"年"整体覆盖内置数据（远程有该年则该年以远程为准）。
final class HolidayDatabase {

    static let shared = HolidayDatabase()

    /// 远程数据源（按顺序回退；国内可达性：fastly > cdn > raw.githubusercontent）
    /// 数据即本仓库 holidays.json 的镜像，更新放假安排只需 git push
    static let fallbackURLs: [URL] = [
        URL(string: "https://fastly.jsdelivr.net/gh/RockyAo/StatusbarCalender@main/StatusbarCalendar/Resources/holidays.json")!,
        URL(string: "https://cdn.jsdelivr.net/gh/RockyAo/StatusbarCalender@main/StatusbarCalendar/Resources/holidays.json")!,
        URL(string: "https://raw.githubusercontent.com/RockyAo/StatusbarCalender/main/StatusbarCalendar/Resources/holidays.json")!,
    ]

    /// 自定义数据源（设置页可填，如 Gitee 镜像或自有 OSS；非空时优先）
    static let customURLKey = "holidayCustomURL"
    static let lastUpdateKey = "holidayLastRemoteUpdate"

    private var entries: [String: DayInfo.Kind] = [:]

    private init() {
        reload()
    }

    // MARK: - 查询

    func kind(of date: Date) -> DayInfo.Kind {
        let c = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = c.year, let month = c.month, let day = c.day else { return .normal }
        return entries[String(format: "%d-%02d-%02d", year, month, day)] ?? .normal
    }

    func isStatutoryOff(_ date: Date) -> Bool {
        kind(of: date) == .statutoryOff
    }

    // MARK: - 数据装载

    /// 内置 + 已缓存远程数据合并（主线程调用）
    func reload() {
        var merged: [String: DayInfo.Kind] = [:]
        var remoteYears: Set<String> = []

        if let cached = try? Data(contentsOf: Self.cacheURL),
           let (parsed, years) = Self.parse(cached) {
            merged.merge(parsed) { _, new in new }
            remoteYears = years
        }

        if let bundled = Self.bundledData, let (parsed, _) = Self.parse(bundled) {
            // 内置数据补充远程没有的年份
            for (key, kind) in parsed where !remoteYears.contains(String(key.prefix(4))) {
                merged[key] = kind
            }
        }
        entries = merged
    }

    /// 拉取远程数据：依次尝试自定义源 + 内置回退源，成功即停
    func fetchRemote() async -> String? {
        var sources = Self.fallbackURLs
        if let custom = UserDefaults.standard.string(forKey: Self.customURLKey),
           let url = URL(string: custom), !custom.isEmpty {
            sources.insert(url, at: 0)
        }

        var lastError = "无可用数据源"
        for url in sources {
            do {
                var request = URLRequest(url: url)
                request.timeoutInterval = 10
                request.cachePolicy = .reloadIgnoringLocalCacheData
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                    lastError = "\(url.host ?? "") 返回异常"
                    continue
                }
                guard let (parsed, _) = Self.parse(data), !parsed.isEmpty else {
                    lastError = "数据格式无效"
                    continue
                }
                try data.write(to: Self.cacheURL, options: .atomic)
                UserDefaults.standard.set(Date(), forKey: Self.lastUpdateKey)
                return nil
            } catch {
                lastError = "\(url.host ?? "")：\(error.localizedDescription)"
            }
        }
        return lastError
    }

    // MARK: - 私有

    private static var cacheURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("StatusbarCalendar", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("holidays-remote.json")
    }

    private static var bundledData: Data? {
        guard let url = Bundle.main.url(forResource: "holidays", withExtension: "json") else { return nil }
        return try? Data(contentsOf: url)
    }

    /// 解析并校验：{ "2026": { "holidays": ["MM-DD"], "workdays": ["MM-DD"] } }
    /// 返回（条目, 覆盖的年份集合）；格式不合法返回 nil
    private static func parse(_ data: Data) -> ([String: DayInfo.Kind], Set<String>)? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        var entries: [String: DayInfo.Kind] = [:]
        var years: Set<String> = []
        for (key, value) in json {
            guard key.count == 4, Int(key) != nil,
                  let dict = value as? [String: [String]] else { continue }
            for mmdd in dict["holidays"] ?? [] {
                entries["\(key)-\(mmdd)"] = .statutoryOff
            }
            for mmdd in dict["workdays"] ?? [] {
                entries["\(key)-\(mmdd)"] = .swappedWorkday
            }
            years.insert(key)
        }
        return (entries, years)
    }
}
