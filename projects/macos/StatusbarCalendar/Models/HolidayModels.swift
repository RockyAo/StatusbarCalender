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
    let data: [HolidayDay]
}

/// 单个节假日数据
struct HolidayDay: Codable, Sendable {
    let date: String       // 完整日期 YYYY-MM-DD
    let days: Int          // 假期总天数（补班为0）
    let holiday: Bool      // true=假期, false=补班
    let name: String       // 节日名称
}

/// 本地存储的节假日记录
struct StoredHoliday: Codable, Sendable {
    let date: String       // YYYY-MM-DD
    let isHoliday: Bool    // true=假期, false=补班
    let name: String       // 节日名称
    let days: Int          // 假期总天数（补班为0）
    
    init(from holidayDay: HolidayDay) {
        self.date = holidayDay.date
        self.isHoliday = holidayDay.holiday
        self.name = holidayDay.name
        self.days = holidayDay.days
    }
    
    init(date: String, isHoliday: Bool, name: String, days: Int) {
        self.date = date
        self.isHoliday = isHoliday
        self.name = name
        self.days = days
    }
}
