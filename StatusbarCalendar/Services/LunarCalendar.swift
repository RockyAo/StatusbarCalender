import Foundation

/// 农历计算：基于系统 `Calendar(identifier: .chinese)`，无外部数据依赖
enum LunarCalendar {

    private static let calendar = Calendar(identifier: .chinese)

    private static let monthNames = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "腊月",
    ]
    private static let dayNames = [
        "初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
        "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
        "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十",
    ]
    private static let stems = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    private static let branches = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
    private static let zodiacs = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]

    // MARK: - 基础信息

    static func components(of date: Date) -> (month: Int, isLeapMonth: Bool, day: Int, year: Int) {
        let comps = calendar.dateComponents([.year, .month, .day], from: date)
        let isLeap = calendar.dateComponents([.isLeapMonth], from: date).isLeapMonth ?? false
        return (comps.month ?? 1, isLeap, comps.day ?? 1, comps.year ?? 1)
    }

    static func dayName(of date: Date) -> String {
        dayNames[components(of: date).day - 1]
    }

    /// 月份名（含闰月前缀），如 "正月"、"闰六月"
    static func monthName(of date: Date) -> String {
        let c = components(of: date)
        return (c.isLeapMonth ? "闰" : "") + monthNames[c.month - 1]
    }

    /// 日历格子副标签：初一显示月份名，其余显示日名
    static func tileLabel(of date: Date) -> String {
        let c = components(of: date)
        return c.day == 1 ? monthName(of: date) : dayNames[c.day - 1]
    }

    /// 干支年 + 生肖，如 "丙午马年"
    static func yearName(of date: Date) -> String {
        let year = components(of: date).year
        let stem = stems[(year - 1) % 10]
        let branch = branches[(year - 1) % 12]
        let zodiac = zodiacs[(year - 1) % 12]
        return "\(stem)\(branch)\(zodiac)年"
    }

    /// 完整农历日期描述，如 "丙午马年 八月十五"
    static func fullDescription(of date: Date) -> String {
        let c = components(of: date)
        let day = dayNames[c.day - 1]
        let month = monthNames[c.month - 1]
        return "\(yearName(of: date)) \(c.isLeapMonth ? "闰" : "")\(month)\(day)"
    }

    // MARK: - 农历节日（按农历月-日）

    private static let lunarFestivals: [Int: [String: String]] = [
        1: ["1": "春节", "15": "元宵节"],
        5: ["5": "端午节"],
        7: ["7": "七夕", "15": "中元节"],
        8: ["15": "中秋节"],
        9: ["9": "重阳节"],
        12: ["8": "腊八节"],
    ]

    static func lunarFestival(on date: Date) -> String? {
        let c = components(of: date)
        return lunarFestivals[c.month]?["\(c.day)"]
    }

    /// 除夕：次日是正月初一
    static func isNewYearEve(_ date: Date) -> Bool {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: date) else { return false }
        let c = components(of: next)
        return c.month == 1 && c.day == 1 && !c.isLeapMonth
    }

    // MARK: - 公历节日

    /// (月, 日) -> 节日名；周节日单独计算
    private static let solarFestivals: [Int: [Int: String]] = [
        1: [1: "元旦"],
        2: [14: "情人节"],
        3: [8: "妇女节", 12: "植树节"],
        4: [1: "愚人节"],
        5: [1: "劳动节", 4: "青年节"],
        6: [1: "儿童节"],
        7: [1: "建党节"],
        8: [1: "建军节"],
        9: [10: "教师节"],
        10: [1: "国庆节", 31: "万圣节"],
        11: [11: "双十一"],
        12: [24: "平安夜", 25: "圣诞节"],
    ]

    static func solarFestival(on date: Date) -> String? {
        let c = Calendar.current.dateComponents([.month, .day], from: date)
        return solarFestivals[c.month ?? 0]?[c.day ?? 0]
    }

    /// 母亲节（5月第二个周日）/ 父亲节（6月第三个周日）/ 感恩节（11月第四个周四）
    /// 用“本月第 N 个周 X”判定：ordinal = (day - 1) / 7 + 1，不受周首日设置影响
    static func weekdayFestival(on date: Date) -> String? {
        let c = Calendar.current.dateComponents([.month, .day, .weekday], from: date)
        guard let month = c.month, let day = c.day, let weekday = c.weekday else { return nil }
        let ordinal = (day - 1) / 7 + 1
        switch (month, weekday, ordinal) {
        case (5, 1, 2): return "母亲节"
        case (6, 1, 3): return "父亲节"
        case (11, 5, 4): return "感恩节"
        default: return nil
        }
    }

    /// 当日最值得展示的节日名（除夕 > 农历 > 周节日 > 公历）
    static func festival(on date: Date) -> String? {
        if isNewYearEve(date) { return "除夕" }
        if let f = lunarFestival(on: date) { return f }
        if let f = weekdayFestival(on: date) { return f }
        return solarFestival(on: date)
    }

    /// 距下一个春节（正月初一）的天数
    static func daysToNextSpringFestival(from date: Date) -> Int? {
        let gregorian = Calendar.current
        for offset in 0...400 {
            guard let candidate = gregorian.date(byAdding: .day, value: offset, to: date) else { continue }
            let c = components(of: candidate)
            if c.month == 1 && c.day == 1 && !c.isLeapMonth {
                return offset
            }
        }
        return nil
    }
}
