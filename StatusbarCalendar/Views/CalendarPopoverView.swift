import SwiftUI

/// 菜单栏弹出的主面板：头部导航 + 月历 + 当日详情 + 事件列表（设置页内嵌切换）
struct CalendarPopoverView: View {
    @EnvironmentObject var app: AppState
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 8) {
            if showSettings {
                SettingsView(onDone: {
                    withAnimation(.easeInOut(duration: 0.15)) { showSettings = false }
                })
            } else {
                header
                MonthGridView()
                dayDetail
                if app.showEvents {
                    EventsListView()
                }
            }
        }
        .padding(.vertical, 10)
        .frame(width: 320)
        .background(.background.opacity(0.001))
        .onAppear { app.reloadEvents() }
    }

    // MARK: - 头部：上月 / 标题（今天）/ 下月 + 设置

    private var header: some View {
        HStack(spacing: 4) {
            navButton("chevron.left") { app.move(byMonths: -1) }

            Button {
                app.moveToToday()
            } label: {
                Text(CalendarManager.monthTitle(for: app.currentMonth))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)

            navButton("chevron.right") { app.move(byMonths: 1) }
            Divider().frame(height: 14)
            navButton("gearshape", iconSize: 12) {
                withAnimation(.easeInOut(duration: 0.15)) { showSettings = true }
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 12)
    }

    private func navButton(_ icon: String, iconSize: CGFloat = 11, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - 当日详情条：农历全称 / 节日 / 距春节

    private var dayDetail: some View {
        let date = app.selectedDate
        let festival = LunarCalendar.festival(on: date)
        let springFestivalDays = LunarCalendar.daysToNextSpringFestival(from: date)

        return HStack(spacing: 6) {
            if let festival {
                Text(festival)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color(nsColor: .systemRed))
            }
            Text(LunarCalendar.fullDescription(of: date))
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Spacer()
            if let days = springFestivalDays, days > 0 {
                Text("距春节 \(days) 天")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
        .padding(.horizontal, 12)
    }
}
