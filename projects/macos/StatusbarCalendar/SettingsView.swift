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
                
                // 面板触发方式
                Section {
                    Picker("触发方式", selection: $clockManager.displayOptions.triggerMode) {
                        Text("点击触发").tag(TriggerMode.click)
                        Text("鼠标悬停").tag(TriggerMode.hover)
                    }
                    
                    // 如果选择悬停模式，显示权限提示
                    if clockManager.displayOptions.triggerMode == .hover {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundStyle(.orange)
                                    .font(.system(size: 14))
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("需要辅助功能权限")
                                        .font(.system(size: 12, weight: .medium))
                                    
                                    Text("鼠标悬停功能需要辅助功能权限才能正常工作")
                                        .font(.system(size: 11))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Button("打开系统设置") {
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                                    NSWorkspace.shared.open(url)
                                }
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("面板显示")
                } footer: {
                    if clockManager.displayOptions.triggerMode == .click {
                        Text("点击状态栏图标打开日历面板")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("鼠标移到状态栏图标上方 0.3 秒后自动打开面板")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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
