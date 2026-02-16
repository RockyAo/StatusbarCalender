//
//  CalendarManager.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import Foundation
import Observation

@Observable
@MainActor
final class CalendarManager {
    var currentDate: Date = Date()
    var selectedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let lunarCalendar = LunarCalendar()
    private var holidayService: HolidayService?
    
    /// 设置节假日服务
    func setHolidayService(_ service: HolidayService) {
        self.holidayService = service
    }
    
    var displayedMonthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: selectedMonth)
    }
    
    var weekdaySymbols: [String] {
        ["日", "一", "二", "三", "四", "五", "六"]
    }
    
    /// 获取当前显示月份的所有日期信息
    func daysInMonth() -> [DayInfo] {
        var days: [DayInfo] = []
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1) else {
            return days
        }
        
        var currentDate = monthFirstWeek.start
        let endDate = monthLastWeek.end
        
        while currentDate < endDate {
            let day = calendar.component(.day, from: currentDate)
            let isCurrentMonth = calendar.isDate(currentDate, equalTo: selectedMonth, toGranularity: .month)
            let isToday = calendar.isDateInToday(currentDate)
            let lunarText = lunarCalendar.lunarDateString(from: currentDate)
            
            // 查询节假日状态
            let status = holidayService?.getStatus(for: currentDate) ?? .normal
            let holidayName = holidayService?.getHolidayName(for: currentDate)
            
            let dayInfo = DayInfo(
                date: currentDate,
                day: day,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                lunarText: lunarText,
                status: status,
                holidayName: holidayName,
                isSolarTerm: false,
                isFestival: false
            )
            
            days.append(dayInfo)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return days
    }
    
    /// 切换到上个月
    func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    /// 切换到下个月
    func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedMonth) {
            selectedMonth = newDate
        }
    }
    
    /// 回到今天
    func goToToday() {
        selectedMonth = Date()
        currentDate = Date()
    }
}
