//
//  MenuBarView.swift
//  StatusbarCalendar
//
//  Created on 2026-02-16.
//

import SwiftUI

struct MenuBarView: View {
    @Bindable var clockManager: ClockManager
    @State private var showSettingsWindow = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 时间显示区域
            VStack(alignment: .leading, spacing: 4) {
                Text(clockManager.currentTimeString)
                    .font(.system(size: 24, weight: .medium, design: .monospaced))
                
                Text(formattedDate)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding()
            
            Divider()
            
            // 菜单选项
            Button {
                showSettingsWindow.toggle()
            } label: {
                Label("设置", systemImage: "gear")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            
            Divider()
            
            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("退出", systemImage: "power")
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .frame(width: 200)
        .sheet(isPresented: $showSettingsWindow) {
            SettingsView(clockManager: clockManager)
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}

#Preview {
    MenuBarView(clockManager: ClockManager())
}
