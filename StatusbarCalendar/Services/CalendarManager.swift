import Foundation

/// 月份网格构建：组装 6×7 DayInfo
enum CalendarManager {

    /// 生成指定月份的网格（含前后月补齐）
    static func monthGrid(for base: Date, weekStartsOnMonday: Bool) -> [DayInfo] {
        var cal = Calendar.current
        cal.firstWeekday = weekStartsOnMonday ? 2 : 1

        guard let monthInterval = cal.dateInterval(of: .month, for: base) else { return [] }
        let firstDay = monthInterval.start
        let today = cal.startOfDay(for: Date())

        // 该月第一天所在周的起始日
        let firstWeekday = cal.component(.weekday, from: firstDay)
        let leading = (firstWeekday - cal.firstWeekday + 7) % 7
        let gridStart = cal.date(byAdding: .day, value: -leading, to: firstDay) ?? firstDay

        var result: [DayInfo] = []
        result.reserveCapacity(42)
        for offset in 0..<42 {
            guard let date = cal.date(byAdding: .day, value: offset, to: gridStart) else { continue }
            result.append(buildDayInfo(date, monthInterval: monthInterval, today: today, calendar: cal))
        }
        return result
    }

    static func buildDayInfo(
        _ date: Date, monthInterval: DateInterval, today: Date, calendar cal: Calendar
    ) -> DayInfo {
        let day = cal.component(.day, from: date)
        let weekday = cal.component(.weekday, from: date)
        return DayInfo(
            date: date,
            day: day,
            isToday: cal.isDate(date, inSameDayAs: today),
            isInMonth: monthInterval.contains(date),
            isWeekend: weekday == 1 || weekday == 7,
            lunarLabel: LunarCalendar.tileLabel(of: date),
            festivalName: LunarCalendar.festival(on: date),
            kind: HolidayDatabase.shared.kind(of: date)
        )
    }

    /// 星期表头符号
    static func weekdaySymbols(weekStartsOnMonday: Bool) -> [String] {
        let base = Calendar.current.veryShortWeekdaySymbols // [日, 一, 二, ..., 六]（本地化，英文为 S,M,T,...）
        return weekStartsOnMonday ? Array(base[1...]) + [base[0]] : base
    }

    /// 月份标题，如 "2026年11月"
    static func monthTitle(for date: Date) -> String {
        let c = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(c.year ?? 0)年\(c.month ?? 0)月"
    }
}
