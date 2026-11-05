import Foundation
import ServiceManagement
import SwiftUI

/// 全局状态与用户设置
@MainActor
final class AppState: ObservableObject {

    enum StatusBarMode: String, CaseIterable, Identifiable {
        case dateOnly = "仅日期"
        case dateAndLunar = "日期 + 农历"
        case dateAndWeekday = "日期 + 星期"
        var id: String { rawValue }
    }

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
    @Published var statusBarModeRaw: String = Defaults.string(forKey: .statusBarMode, default: AppState.StatusBarMode.dateAndLunar.rawValue) {
        didSet {
            Defaults.set(statusBarModeRaw, forKey: .statusBarMode)
            refreshStatusText()
        }
    }
    @Published var launchAtLogin: Bool = Defaults.bool(forKey: .launchAtLogin, default: false) {
        didSet {
            Defaults.set(launchAtLogin, forKey: .launchAtLogin)
            syncLoginItem()
        }
    }

    var statusBarMode: StatusBarMode {
        StatusBarMode(rawValue: statusBarModeRaw) ?? .dateAndLunar
    }

    let eventStore = EventStoreManager()

    private var minuteTimer: Timer?

    // MARK: - 初始化

    init() {
        refreshStatusText()
        minuteTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refreshStatusText() }
        }
        if launchAtLogin { syncLoginItem() }
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

    // MARK: - 菜单栏文字

    func refreshStatusText() {
        let now = Date()
        let cal = Calendar.current
        let c = cal.dateComponents([.month, .day], from: now)
        let datePart = "\(c.month ?? 0)月\(c.day ?? 0)日"
        switch statusBarMode {
        case .dateOnly:
            statusText = datePart
        case .dateAndWeekday:
            let symbol = cal.veryShortWeekdaySymbols[cal.component(.weekday, from: now) - 1]
            statusText = "\(datePart) 周\(symbol)"
        case .dateAndLunar:
            if let festival = LunarCalendar.festival(on: now) {
                statusText = "\(datePart) \(festival)"
            } else {
                statusText = "\(datePart) \(LunarCalendar.tileLabel(of: now))"
            }
        }
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
        case statusBarMode
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

    static func string(forKey key: Key, default defaultValue: String) -> String {
        UserDefaults.standard.string(forKey: key.rawValue) ?? defaultValue
    }

    static func set(_ value: String, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
}
