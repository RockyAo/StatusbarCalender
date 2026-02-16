//
//  CalendarGridView.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

struct CalendarGridView: View {
    @Bindable var calendarManager: CalendarManager
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        VStack(spacing: 12) {
            // 月份切换头部
            HStack {
                HStack(spacing: 4) {
                    Text(calendarManager.displayedMonthYear)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Button(action: { calendarManager.previousMonth() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { calendarManager.goToToday() }) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Button(action: { calendarManager.nextMonth() }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(.horizontal, 4)
            
            // 星期标题
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendarManager.weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(weekday == "日" || weekday == "六" ? Color.secondary.opacity(0.5) : .secondary)
                        .frame(height: 20)
                }
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // 日期网格
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendarManager.daysInMonth()) { dayInfo in
                    DayCell(dayInfo: dayInfo)
                }
            }
            
            Divider()
                .padding(.vertical, 2)
            
            // 底部操作按钮
            HStack {
                Text(getLunarYearInfo())
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .frame(width: 380)
    }
    
    private func getLunarYearInfo() -> String {
        let lunar = LunarCalendar()
        return lunar.fullLunarInfo(from: Date())
    }
}

#Preview {
    CalendarGridView(calendarManager: CalendarManager())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
}
