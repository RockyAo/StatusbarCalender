//
//  HolidayModels.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation

/// API 响应根结构
struct HolidayResponse: Codable, Sendable {
    let code: Int
    let holiday: [String: HolidayDay]
}

/// 单个节假日数据
struct HolidayDay: Codable, Sendable {
    let holiday: Bool      // true=休息日, false=补班日
    let name: String       // 节日名称
    let wage: Int          // 工资倍数
    let date: String       // 完整日期 YYYY-MM-DD
    let rest: Int          // 距离今天的天数
    let after: Bool?       // 是否为节后补班
    let target: String?    // 补班对应的节日
}

/// 本地存储的节假日记录
struct StoredHoliday: Codable, Sendable {
    let date: String       // YYYY-MM-DD
    let isHoliday: Bool    // true=休, false=班
    let name: String       // 节日名称
    let wage: Int          // 工资倍数
    
    init(from holidayDay: HolidayDay) {
        self.date = holidayDay.date
        self.isHoliday = holidayDay.holiday
        self.name = holidayDay.name
        self.wage = holidayDay.wage
    }
    
    init(date: String, isHoliday: Bool, name: String, wage: Int) {
        self.date = date
        self.isHoliday = isHoliday
        self.name = name
        self.wage = wage
    }
}
