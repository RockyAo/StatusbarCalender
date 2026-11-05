import Foundation
import ServiceManagement
import SwiftUI

/// 全局状态与用户设置
@MainActor
final class AppState: ObservableObject {

    /// AppDelegate 与 SwiftUI 视图共享的唯一实例
    static let shared = AppState()

    private static let weekdayNames = ["日", "一", "二", "三", "四", "五", "六"]
    private static let time24: DateFormatter = { let f = DateFormatter(); f.dateFormat = "HH:mm"; return f }()
    private static let time12: DateFormatter = { let f = DateFormatter(); f.dateFormat = "h:mm a"; return f }()

    // MARK: - 视图状态

    @Published var currentMonth: Date = Date()   // 当前展示的月份
    @Published var selectedDate: Date = Date()   // 选中的日期
    @Published var statusText: String = ""       // 菜单栏文字

    // MARK: - 用户设置（UserDefaults 持久化，变更即时通知视图）

    @Published var showLunar: Bool = Defaults.bool(forKey: .showLunar, default: true) {
        didSet { Defaults.set(showLunar, forKey: .showLunar) }
    }
    @Published var showFestival: Bool = Defaults.bool(forKey: .showFestival, default: true) {
        didSet { Defaults.set(showFestival, forKey: .showFestival) }
    }
    @Published var showHolidayBadge: Bool = Defaults.bool(forKey: .showHolidayBadge, default: true) {
        didSet { Defaults.set(showHolidayBadge, forKey: .showHolidayBadge) }
    }
    @Published var showEvents: Bool = Defaults.bool(forKey: .showEvents, default: false) {
        didSet {
            Defaults.set(showEvents, forKey: .showEvents)
            handleEventToggle()
        }
    }
    @Published var weekStartsOnMonday: Bool = Defaults.bool(forKey: .weekStartsOnMonday, default: true) {
        didSet { Defaults.set(weekStartsOnMonday, forKey: .weekStartsOnMonday) }
    }
    // MARK: - 菜单栏文字配置（年份 / 月日 / 星期 / 农历 / 时间 独立开关）

    @Published var statusShowYear = Defaults.bool(forKey: .statusShowYear, default: false) {
        didSet { Defaults.set(statusShowYear, forKey: .statusShowYear); refreshStatusText() }
    }
    @Published var statusShowDate = Defaults.bool(forKey: .statusShowDate, default: true) {
        didSet { Defaults.set(statusShowDate, forKey: .statusShowDate); refreshStatusText() }
    }
    @Published var statusShowWeekday = Defaults.bool(forKey: .statusShowWeekday, default: false) {
        didSet { Defaults.set(statusShowWeekday, forKey: .statusShowWeekday); refreshStatusText() }
    }
    @Published var statusShowLunar = Defaults.bool(forKey: .statusShowLunar, default: true) {
        didSet { Defaults.set(statusShowLunar, forKey: .statusShowLunar); refreshStatusText() }
    }
    @Published var statusShowTime = Defaults.bool(forKey: .statusShowTime, default: false) {
        didSet {
            Defaults.set(statusShowTime, forKey: .statusShowTime)
            refreshStatusText()
            resetStatusTimer()
        }
    }
    @Published var statusUse24Hour = Defaults.bool(forKey: .statusUse24Hour, default: true) {
        didSet { Defaults.set(statusUse24Hour, forKey: .statusUse24Hour); refreshStatusText() }
    }
    @Published var launchAtLogin: Bool = Defaults.bool(forKey: .launchAtLogin, default: false) {
        didSet {
            Defaults.set(launchAtLogin, forKey: .launchAtLogin)
            syncLoginItem()
        }
    }

    let eventStore = EventStoreManager()

    private var statusTimer: Timer?

    // MARK: - 节假日远程数据

    /// 节假日数据版本号：远程更新成功后 +1，驱动日历网格重算
    @Published var holidayTick = 0
    @Published var holidayStatus = ""
    @Published var holidayCustomURL = UserDefaults.standard.string(forKey: HolidayDatabase.customURLKey) ?? "" {
        didSet { UserDefaults.standard.set(holidayCustomURL, forKey: HolidayDatabase.customURLKey) }
    }

    private static let holidayTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm"
        return f
    }()

    /// 上次远程更新时间（设置页展示）；nil = 从未
    var holidayLastUpdateText: String {
        guard let date = UserDefaults.standard.object(forKey: HolidayDatabase.lastUpdateKey) as? Date else {
            return "从未（使用内置数据）"
        }
        return Self.holidayTimeFormatter.string(from: date)
    }

    // MARK: - 初始化

    init() {
        refreshStatusText()
        resetStatusTimer()
        if launchAtLogin { syncLoginItem() }
        Task { await autoRefreshHolidays() }
    }

    /// 距上次成功拉取超过 24 小时才自动刷新（静默）
    private func autoRefreshHolidays() async {
        let last = UserDefaults.standard.object(forKey: HolidayDatabase.lastUpdateKey) as? Date
        if let last, Date().timeIntervalSince(last) < 24 * 3600 { return }
        await checkHolidayUpdates(showStatus: false)
    }

    func checkHolidayUpdates(showStatus: Bool = true) async {
        if showStatus { holidayStatus = "正在检查更新…" }
        if let error = await HolidayDatabase.shared.fetchRemote() {
            holidayStatus = "更新失败：\(error)"
        } else {
            HolidayDatabase.shared.reload()
            holidayTick += 1
            holidayStatus = "已更新至最新"
        }
    }

    /// 显示时间时每秒刷新，否则 30 秒
    private func resetStatusTimer() {
        statusTimer?.invalidate()
        let interval: TimeInterval = statusShowTime ? 1 : 30
        statusTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshStatusText() }
        }
    }

    // MARK: - 月份导航

    func moveToToday() {
        let now = Date()
        currentMonth = now
        selectedDate = now
        refreshStatusText()
        reloadEvents()
    }

    func move(byMonths delta: Int) {
        let cal = Calendar.current
        guard let next = cal.date(byAdding: .month, value: delta, to: currentMonth) else { return }
        currentMonth = next
        // 选中日跟随到目标月的 1 号
        var comps = cal.dateComponents([.year, .month], from: next)
        comps.day = 1
        selectedDate = cal.date(from: comps) ?? next
        reloadEvents()
    }

    func select(_ date: Date) {
        selectedDate = date
        let cal = Calendar.current
        if !cal.isDate(date, equalTo: currentMonth, toGranularity: .month) {
            currentMonth = date
            reloadEvents()
        }
    }

    func reloadEvents() {
        guard showEvents else { return }
        eventStore.reloadEvents(around: currentMonth)
    }

    private func handleEventToggle() {
        Task {
            if showEvents {
                await eventStore.requestAccess()
                reloadEvents()
            } else {
                eventStore.markOff()
            }
        }
    }

    // MARK: - 菜单栏文字（年份 / 月日 / 星期 / 农历 / 时间 自由组合）

    func refreshStatusText() {
        let now = Date()
        let c = Calendar.current.dateComponents([.year, .month, .day, .weekday], from: now)

        var datePart = ""
        if statusShowYear, let year = c.year { datePart += "\(year)年" }
        if statusShowDate { datePart += "\(c.month ?? 0)月\(c.day ?? 0)日" }

        var parts: [String] = []
        if !datePart.isEmpty { parts.append(datePart) }
        if statusShowWeekday, let weekday = c.weekday {
            parts.append("周\(Self.weekdayNames[weekday - 1])")
        }
        if statusShowLunar {
            parts.append(LunarCalendar.festival(on: now) ?? LunarCalendar.tileLabel(of: now))
        }
        if statusShowTime {
            parts.append((statusUse24Hour ? Self.time24 : Self.time12).string(from: now))
        }
        statusText = parts.joined(separator: " ")
    }

    // MARK: - 开机启动

    private func syncLoginItem() {
        let service = SMAppService.mainApp
        do {
            if launchAtLogin, service.status != .enabled {
                try service.register()
            } else if !launchAtLogin, service.status == .enabled {
                try service.unregister()
            }
        } catch {
            NSLog("SMAppService error: \(error.localizedDescription)")
        }
    }
}

/// UserDefaults 键名与读写封装
private enum Defaults {

    enum Key: String {
        case showLunar
        case showFestival
        case showHolidayBadge
        case showEvents
        case weekStartsOnMonday
        case statusShowYear
        case statusShowDate
        case statusShowWeekday
        case statusShowLunar
        case statusShowTime
        case statusUse24Hour
        case launchAtLogin
    }

    static func bool(forKey key: Key, default defaultValue: Bool) -> Bool {
        UserDefaults.standard.object(forKey: key.rawValue) == nil
            ? defaultValue
            : UserDefaults.standard.bool(forKey: key.rawValue)
    }

    static func set(_ value: Bool, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
