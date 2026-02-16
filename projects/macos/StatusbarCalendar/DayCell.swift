//
//  DayCell.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

struct DayCell: View {
    let dayInfo: DayInfo
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 背景和内容
            VStack(spacing: 2) {
                // 日期数字
                Text("\(dayInfo.day)")
                    .font(.system(size: 14, weight: dayInfo.isToday ? .semibold : .medium))
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity)
                
                // 农历文字
                if !dayInfo.lunarText.isEmpty {
                    Text(dayInfo.lunarText)
                        .font(.system(size: 10))
                        .foregroundStyle(lunarTextColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // 节假日标记 - 左上角小圆点
            if let statusText = dayInfo.status.displayText {
                Text(statusText)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 14, height: 14)
                    .background(statusBackgroundColor)
                    .clipShape(Circle())
                    .offset(x: 4, y: 4)
            }
        }
    }
    
    // MARK: - Colors
    
    private var textColor: Color {
        if !dayInfo.isCurrentMonth {
            return Color.secondary.opacity(0.4)
        }
        
        if dayInfo.isToday {
            return .white
        }
        
        return Color.primary
    }
    
    private var lunarTextColor: Color {
        if !dayInfo.isCurrentMonth {
            return Color.secondary.opacity(0.3)
        }
        
        if dayInfo.isToday {
            return Color.white.opacity(0.9)
        }
        
        // 节气和节日用红色
        if dayInfo.isSolarTerm || dayInfo.isFestival {
            return Color.red.opacity(0.8)
        }
        
        return Color.secondary.opacity(0.7)
    }
    
    private var backgroundColor: Color {
        if dayInfo.isToday {
            return Color.blue
        }
        
        if dayInfo.status == .holiday {
            return Color.red.opacity(0.08)
        }
        
        if dayInfo.status == .workday {
            return Color.orange.opacity(0.08)
        }
        
        return Color.clear
    }
    
    private var statusBackgroundColor: Color {
        switch dayInfo.status {
        case .holiday:
            return Color.red
        case .workday:
            return Color.orange
        case .normal:
            return Color.clear
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        HStack(spacing: 8) {
            // 普通日期
            DayCell(dayInfo: DayInfo(
                date: Date(),
                day: 15,
                isCurrentMonth: true,
                isToday: false,
                lunarText: "廿三"
            ))
            
            // 今天
            DayCell(dayInfo: DayInfo(
                date: Date(),
                day: 16,
                isCurrentMonth: true,
                isToday: true,
                lunarText: "腊廿九"
            ))
            
            // 节假日（休）
            DayCell(dayInfo: {
                var info = DayInfo(
                    date: Date(),
                    day: 17,
                    isCurrentMonth: true,
                    isToday: false,
                    lunarText: "除夕"
                )
                info.status = .holiday
                return info
            }())
            
            // 补班日
            DayCell(dayInfo: {
                var info = DayInfo(
                    date: Date(),
                    day: 18,
                    isCurrentMonth: true,
                    isToday: false,
                    lunarText: "初一"
                )
                info.status = .workday
                return info
            }())
            
            // 上月日期（非当月）
            DayCell(dayInfo: DayInfo(
                date: Date(),
                day: 30,
                isCurrentMonth: false,
                isToday: false,
                lunarText: "廿一"
            ))
        }
    }
    .padding()
    .frame(width: 380)
}
