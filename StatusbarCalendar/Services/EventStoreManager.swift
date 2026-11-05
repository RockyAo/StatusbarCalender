import EventKit
import Foundation

/// EventKit 封装：仅在用户开启"显示系统日历事件"后请求权限并读取
@MainActor
final class EventStoreManager: ObservableObject {

    enum AccessState {
        case off           // 未开启
        case pending       // 已请求等待授权
        case denied        // 用户拒绝
        case granted       // 已授权
    }

    @Published private(set) var accessState: AccessState = .off
    @Published private(set) var monthEvents: [Date: [EKEvent]] = [:]

    private let store = EKEventStore()

    /// 请求日历读取权限（macOS 14+ 用 full access）
    func requestAccess() async {
        accessState = .pending
        do {
            let granted = try await store.requestFullAccessToEvents()
            accessState = granted ? .granted : .denied
        } catch {
            accessState = .denied
        }
    }

    func markOff() {
        accessState = .off
        monthEvents = [:]
    }

    /// 拉取某月的日历事件，按"天"归组
    func reloadEvents(around date: Date) {
        guard accessState == .granted else { return }
        var cal = Calendar.current
        cal.timeZone = .current
        guard let interval = cal.dateInterval(of: .month, for: date) else { return }
        // 前后各扩 7 天，覆盖网格中显示的相邻月日期
        let start = interval.start.addingTimeInterval(-7 * 86_400)
        let end = interval.end.addingTimeInterval(7 * 86_400)

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: nil)
        let events = store.events(matching: predicate)
        var grouped: [Date: [EKEvent]] = [:]
        for event in events {
            let key = cal.startOfDay(for: event.startDate)
            grouped[key, default: []].append(event)
        }
        monthEvents = grouped
    }

    func events(on day: Date) -> [EKEvent] {
        let cal = Calendar.current
        return (monthEvents[cal.startOfDay(for: day)] ?? [])
            .sorted { $0.startDate < $1.startDate }
    }

    func hasEvent(on day: Date) -> Bool {
        monthEvents[Calendar.current.startOfDay(for: day)] != nil
    }
}
