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
                Section("菜单栏显示") {
                    Toggle("显示年份", isOn: $app.statusShowYear)
                    Toggle("显示月日", isOn: $app.statusShowDate)
                    Toggle("显示星期", isOn: $app.statusShowWeekday)
                    Toggle("显示农历", isOn: $app.statusShowLunar)
                    Toggle("显示时间", isOn: $app.statusShowTime)
                    Picker("时间制式", selection: $app.statusUse24Hour) {
                        Text("24 小时制").tag(true)
                        Text("12 小时制").tag(false)
                    }
                    .disabled(!app.statusShowTime)
                    LabeledContent("当前效果", value: app.statusText)
                }

                Section("通用") {
                    Toggle("登录时自动启动", isOn: $app.launchAtLogin)
                    Toggle("一周从周一开始", isOn: $app.weekStartsOnMonday)
                }

                Section("日历显示") {
                    Toggle("显示农历", isOn: $app.showLunar)
                    Toggle("显示节日", isOn: $app.showFestival)
                    Toggle("显示节假日休/班标记", isOn: $app.showHolidayBadge)
                    Toggle("显示系统日历事件", isOn: $app.showEvents)
                }

                Section("关于") {
                    LabeledContent("版本", value: "2.0")
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 320, height: 470)
    }
}
