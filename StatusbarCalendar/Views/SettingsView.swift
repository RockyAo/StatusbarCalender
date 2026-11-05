import SwiftUI

/// 设置页（内嵌在菜单栏弹窗中，点“完成”返回日历）
struct SettingsView: View {
    @EnvironmentObject var app: AppState
    var onDone: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("设置")
                    .font(.system(size: 13, weight: .semibold))
                Spacer()
                Button("完成") { onDone?() }
                    .buttonStyle(.link)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)

            Divider()

            Form {
                Section("通用") {
                    Toggle("登录时自动启动", isOn: $app.launchAtLogin)
                    Toggle("一周从周一开始", isOn: $app.weekStartsOnMonday)
                    Picker("菜单栏显示", selection: $app.statusBarModeRaw) {
                        ForEach(AppState.StatusBarMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode.rawValue)
                        }
                    }
                }

                Section("日历显示") {
                    Toggle("显示农历", isOn: $app.showLunar)
                    Toggle("显示节日", isOn: $app.showFestival)
                    Toggle("显示节假日休/班标记", isOn: $app.showHolidayBadge)
                    Toggle("显示系统日历事件", isOn: $app.showEvents)
                }

                Section("关于") {
                    LabeledContent("版本", value: "2.0")
                    LabeledContent("节假日数据", value: "内置 2025–2026，json 可更新")
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 320, height: 372)
    }
}
