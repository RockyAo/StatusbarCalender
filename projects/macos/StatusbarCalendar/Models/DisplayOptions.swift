//
//  DisplayOptions.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation

/// 时间格式
enum TimeFormat: String, Codable {
    case twentyFourHour = "24h"
    case twelveHour = "12h"
}

/// 面板触发方式
enum TriggerMode: String, Codable {
    case click = "click"     // 点击触发
    case hover = "hover"     // 悬停触发
    
    var displayName: String {
        switch self {
        case .click: return "点击触发"
        case .hover: return "鼠标悬停"
        }
    }
}

/// 状态栏显示选项
struct DisplayOptions: Codable {
    var showDate: Bool = true
    var showLunar: Bool = true
    var showWeekday: Bool = true
    var showTime: Bool = true
    var showSeconds: Bool = true
    var timeFormat: TimeFormat = .twentyFourHour
    var triggerMode: TriggerMode = .click
    
    /// 生成状态栏显示字符串
    func generateStatusBarText(date: Date, lunarText: String, calendar: Calendar) -> String {
        var components: [String] = []
        
        // 日期部分 "2月16日"
        if showDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M月d日"
            components.append(dateFormatter.string(from: date))
        }
        
        // 星期部分 "周日" - 放在农历之前，更简洁
        if showWeekday {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"
            weekdayFormatter.locale = Locale(identifier: "zh_CN")
            let weekdayFull = weekdayFormatter.string(from: date)
            // 转换 "星期日" -> "周日"
            let weekday = weekdayFull.replacingOccurrences(of: "星期", with: "周")
            components.append(weekday)
        }
        
        // 农历部分 - 只显示月日，不显示年份，更简洁
        if showLunar {
            // 从完整农历信息中提取月日部分
            // "农历42年 腊月廿九" -> "腊月廿九"
            let parts = lunarText.components(separatedBy: " ")
            if parts.count >= 2 {
                components.append(parts[1])
            } else {
                components.append(lunarText)
            }
        }
        
        // 时间部分 "14:30:45" 或 "2:30 PM"
        if showTime {
            let timeFormatter = DateFormatter()
            switch timeFormat {
            case .twentyFourHour:
                timeFormatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
            case .twelveHour:
                timeFormatter.dateFormat = showSeconds ? "h:mm:ss a" : "h:mm a"
                timeFormatter.locale = Locale(identifier: "zh_CN")
            }
            components.append(timeFormatter.string(from: date))
        }
        
        return components.joined(separator: " ")
    }
}

/// UserDefaults 扩展 - 持久化显示选项
extension UserDefaults {
    private static let displayOptionsKey = "displayOptions"
    
    var displayOptions: DisplayOptions {
        get {
            guard let data = data(forKey: Self.displayOptionsKey) else {
                return DisplayOptions()
            }
            return (try? JSONDecoder().decode(DisplayOptions.self, from: data)) ?? DisplayOptions()
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            set(data, forKey: Self.displayOptionsKey)
        }
    }
}
