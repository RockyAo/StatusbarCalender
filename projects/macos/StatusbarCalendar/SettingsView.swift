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
        VStack(spacing: 20) {
            Text("设置")
                .font(.title2)
                .fontWeight(.semibold)
            
            Form {
                Section {
                    Toggle("显示秒", isOn: $clockManager.showSeconds)
                        .onChange(of: clockManager.showSeconds) { _, _ in
                            clockManager.toggleShowSeconds()
                        }
                } header: {
                    Text("时间显示")
                }
                
                Section {
                    HStack {
                        Text("当前时间:")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text(clockManager.currentTimeString)
                            .monospacedDigit()
                            .fontWeight(.medium)
                    }
                } header: {
                    Text("预览")
                }
            }
            .formStyle(.grouped)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}

#Preview {
    SettingsView(clockManager: ClockManager())
}
