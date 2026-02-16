//
//  MenuBarView.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

struct MenuBarView: View {
    @Bindable var clockManager: ClockManager
    @State private var calendarManager = CalendarManager()
    @State private var showSettingsWindow = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 当前日期时间信息头部
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedDate)
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text(lunarInfo)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(clockManager.currentTimeString)
                        .font(.system(size: 20, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(12)
            
            Divider()
            
            // 日历网格主体
            CalendarGridView(calendarManager: calendarManager)
            
            Divider()
            
            // 底部菜单选项
            HStack(spacing: 8) {
                Button {
                    showSettingsWindow.toggle()
                } label: {
                    Label("设置", systemImage: "gear")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label("退出", systemImage: "power")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
        .sheet(isPresented: $showSettingsWindow) {
            SettingsView(clockManager: clockManager)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
    
    private var lunarInfo: String {
        let lunar = LunarCalendar()
        return lunar.fullLunarInfo(from: Date())
    }
}

#Preview {
    MenuBarView(clockManager: ClockManager())
        .frame(width: 300, height: 500)
}
