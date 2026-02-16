//
//  DayStatus.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation

/// 节假日类型定义
enum DayStatus: String, Codable, Sendable {
    case holiday // 休息日
    case workday // 调休补班
    case normal  // 普通工作日
    
    var displayText: String? {
        switch self {
        case .holiday: return "休"
        case .workday: return "班"
        case .normal: return nil
        }
    }
}

/// 日期信息模型
struct DayInfo: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let day: Int
    let isCurrentMonth: Bool
    let isToday: Bool
    let lunarText: String
    var status: DayStatus = .normal
    var holidayName: String?
    var isSolarTerm: Bool = false  // 是否是节气
    var isFestival: Bool = false   // 是否是节日
    
    init(date: Date, day: Int, isCurrentMonth: Bool, isToday: Bool, lunarText: String, status: DayStatus = .normal, holidayName: String? = nil, isSolarTerm: Bool = false, isFestival: Bool = false) {
        self.date = date
        self.day = day
        self.isCurrentMonth = isCurrentMonth
        self.isToday = isToday
        self.lunarText = lunarText
        self.status = status
        self.holidayName = holidayName
        self.isSolarTerm = isSolarTerm
        self.isFestival = isFestival
    }
}
