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
                Button(action: { calendarManager.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(calendarManager.displayedMonthYear)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                Button(action: { calendarManager.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)
            
            // 星期标题
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(calendarManager.weekdaySymbols, id: \.self) { weekday in
                    Text(weekday)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(height: 24)
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
                .padding(.vertical, 4)
            
            // 底部操作按钮
            HStack {
                Button("回到今天") {
                    calendarManager.goToToday()
                }
                .buttonStyle(.plain)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 4)
        }
        .padding(12)
        .frame(width: 280)
    }
}

#Preview {
    CalendarGridView(calendarManager: CalendarManager())
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
}
