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
        VStack(spacing: 2) {
            // 日期数字
            ZStack(alignment: .topTrailing) {
                Text("\(dayInfo.day)")
                    .font(.system(size: 14, weight: dayInfo.isToday ? .semibold : .regular))
                    .foregroundStyle(textColor)
                
                // 节假日角标（休/班）
                if let statusText = dayInfo.status.displayText {
                    Text(statusText)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 3)
                        .padding(.vertical, 1)
                        .background(statusBackgroundColor)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .offset(x: 8, y: -8)
                }
            }
            
            // 农历文字
            Text(dayInfo.lunarText)
                .font(.system(size: 9))
                .foregroundStyle(lunarTextColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(borderColor, lineWidth: dayInfo.isToday ? 2 : 0)
        )
    }
    
    // MARK: - Colors
    
    private var textColor: Color {
        if !dayInfo.isCurrentMonth {
            return Color.secondary.opacity(0.3)
        }
        
        if dayInfo.isToday {
            return Color.accentColor
        }
        
        return Color.primary
    }
    
    private var lunarTextColor: Color {
        if !dayInfo.isCurrentMonth {
            return Color.secondary.opacity(0.2)
        }
        
        return Color.secondary.opacity(0.7)
    }
    
    private var backgroundColor: Color {
        if dayInfo.isToday {
            return Color.accentColor.opacity(0.1)
        }
        
        return Color.clear
    }
    
    private var borderColor: Color {
        if dayInfo.isToday {
            return Color.accentColor
        }
        
        return Color.clear
    }
    
    private var statusBackgroundColor: Color {
        switch dayInfo.status {
        case .holiday:
            return Color.red.opacity(0.8)
        case .workday:
            return Color.blue.opacity(0.7)
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
