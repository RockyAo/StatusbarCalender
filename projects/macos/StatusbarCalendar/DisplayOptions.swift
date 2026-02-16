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

/// 状态栏显示选项
struct DisplayOptions: Codable {
    var showDate: Bool = true
    var showLunar: Bool = true
    var showWeekday: Bool = true
    var showTime: Bool = true
    var showSeconds: Bool = true
    var timeFormat: TimeFormat = .twentyFourHour
    
    /// 生成状态栏显示字符串
    func generateStatusBarText(date: Date, lunarText: String, calendar: Calendar) -> String {
        var components: [String] = []
        
        // 日期部分 "2月16日"
        if showDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M月d日"
            components.append(dateFormatter.string(from: date))
        }
        
        // 农历部分 "正月初九"
        if showLunar {
            components.append(lunarText)
        }
        
        // 星期部分 "周日"
        if showWeekday {
            let weekdayFormatter = DateFormatter()
            weekdayFormatter.dateFormat = "EEEE"
            weekdayFormatter.locale = Locale(identifier: "zh_CN")
            let weekdayFull = weekdayFormatter.string(from: date)
            // 转换 "星期日" -> "周日"
            let weekday = weekdayFull.replacingOccurrences(of: "星期", with: "周")
            components.append(weekday)
        }
        
        // 时间部分 "14:30:45" 或 "2:30:45 PM"
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
