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
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(formattedDate)
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        Text(lunarInfo)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(clockManager.currentTimeString)
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundStyle(Color.accentColor)
                }
            }
            .padding(16)
            .padding(.bottom, 4)
            
            Divider()
            
            // 日历网格主体
            CalendarGridView(calendarManager: calendarManager)
            
            Divider()
            
            // 底部菜单选项
            HStack(spacing: 8) {
                Button {
                    showSettingsWindow.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gear")
                            .font(.system(size: 12))
                        Text("设置")
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "power")
                            .font(.system(size: 12))
                        Text("退出")
                            .font(.system(size: 11))
                    }
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .frame(width: 380)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
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
}
