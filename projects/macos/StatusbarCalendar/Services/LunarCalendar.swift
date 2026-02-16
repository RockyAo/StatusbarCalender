//
//  LunarCalendar.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation

/// 农历计算工具类
struct LunarCalendar {
    private let chineseCalendar: Calendar
    
    init() {
        self.chineseCalendar = Calendar(identifier: .chinese)
    }
    
    /// 获取农历日期字符串
    func lunarDateString(from date: Date) -> String {
        let lunarDay = chineseCalendar.component(.day, from: date)
        let lunarMonth = chineseCalendar.component(.month, from: date)
        let isLeapMonth = chineseCalendar.dateComponents([.month], from: date).isLeapMonth ?? false
        
        let monthStr = lunarMonthString(month: lunarMonth, isLeap: isLeapMonth)
        let dayStr = lunarDayString(day: lunarDay)
        
        // 初一显示月份，其他显示日期
        if lunarDay == 1 {
            return monthStr
        } else {
            return dayStr
        }
    }
    
    /// 获取农历月份字符串
    private func lunarMonthString(month: Int, isLeap: Bool) -> String {
        let months = ["正月", "二月", "三月", "四月", "五月", "六月",
                     "七月", "八月", "九月", "十月", "冬月", "腊月"]
        guard month > 0 && month <= months.count else { return "" }
        let prefix = isLeap ? "闰" : ""
        return prefix + months[month - 1]
    }
    
    /// 获取农历日期字符串
    private func lunarDayString(day: Int) -> String {
        if day == 0 { return "" }
        
        let dayCharacters = ["初", "十", "廿", "卅"]
        let numberCharacters = ["一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
        
        if day == 10 {
            return "初十"
        } else if day == 20 {
            return "二十"
        } else if day == 30 {
            return "三十"
        } else if day < 10 {
            return dayCharacters[0] + numberCharacters[day - 1]
        } else if day < 20 {
            return dayCharacters[1] + numberCharacters[day - 11]
        } else if day < 30 {
            return dayCharacters[2] + numberCharacters[day - 21]
        } else {
            return dayCharacters[3] + numberCharacters[day - 31]
        }
    }
    
    /// 获取完整的农历信息（年月日）
    func fullLunarInfo(from date: Date) -> String {
        let lunarYear = chineseCalendar.component(.year, from: date)
        let lunarMonth = chineseCalendar.component(.month, from: date)
        let lunarDay = chineseCalendar.component(.day, from: date)
        let isLeapMonth = chineseCalendar.dateComponents([.month], from: date).isLeapMonth ?? false
        
        let yearStr = "农历\(lunarYear)年"
        let monthStr = lunarMonthString(month: lunarMonth, isLeap: isLeapMonth)
        let dayStr = lunarDayString(day: lunarDay)
        
        return "\(yearStr) \(monthStr)\(dayStr)"
    }
}
