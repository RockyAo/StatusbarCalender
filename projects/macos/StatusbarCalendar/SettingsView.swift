//
//  SettingsView.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

struct SettingsView: View {
    @Bindable var clockManager: ClockManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("设置")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding()
            
            // 设置表单
            Form {
                // 状态栏显示内容
                Section {
                    Toggle("显示日期", isOn: $clockManager.displayOptions.showDate)
                    Toggle("显示农历", isOn: $clockManager.displayOptions.showLunar)
                    Toggle("显示星期", isOn: $clockManager.displayOptions.showWeekday)
                    Toggle("显示时间", isOn: $clockManager.displayOptions.showTime)
                } header: {
                    Text("状态栏显示")
                }
                
                // 时间格式
                Section {
                    Picker("时间格式", selection: $clockManager.displayOptions.timeFormat) {
                        Text("24 小时制").tag(TimeFormat.twentyFourHour)
                        Text("12 小时制").tag(TimeFormat.twelveHour)
                    }
                    
                    Toggle("显示秒", isOn: $clockManager.displayOptions.showSeconds)
                        .disabled(!clockManager.displayOptions.showTime)
                } header: {
                    Text("时间设置")
                }
                
                // 预览
                Section {
                    HStack {
                        Text("预览:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(clockManager.currentTimeString)
                            .fontDesign(.monospaced)
                            .fontWeight(.medium)
                            .font(.system(size: 12))
                    }
                } header: {
                    Text("状态栏预览")
                } footer: {
                    Text("状态栏会实时显示上述选中的内容")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            
            // 底部按钮
            HStack {
                Button("恢复默认") {
                    clockManager.displayOptions = DisplayOptions()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("完成") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 450, height: 550)
    }
}

#Preview {
    SettingsView(clockManager: ClockManager())
}
