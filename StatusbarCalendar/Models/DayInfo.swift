import Foundation

/// 单个日期格子的完整展示信息
struct DayInfo: Identifiable, Equatable {
    enum Kind {
        case normal          // 普通日
        case statutoryOff    // 法定节假日（放假日）
        case swappedWorkday  // 调休补班日
    }

    let date: Date
    let day: Int
    let isToday: Bool
    let isInMonth: Bool
    let isWeekend: Bool
    /// 农历副标题：初一显示月份名，其余显示日名；有节日时由 festivalName 覆盖
    let lunarLabel: String
    /// 节日名（法定/农历/公历节日中优先级最高者）
    let festivalName: String?
    let kind: Kind

    var id: Date { date }

    /// 格子副标签：节日 > 农历
    var subLabel: String { festivalName ?? lunarLabel }

    var isFestival: Bool { festivalName != nil }
}
