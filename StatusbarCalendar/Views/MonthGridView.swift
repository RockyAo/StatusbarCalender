import SwiftUI

/// 月历网格：星期表头 + 6×7 日期格，支持左右滑动翻月
struct MonthGridView: View {
    @EnvironmentObject var app: AppState

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        // 引用 holidayTick：节假日远程数据更新后触发网格重算
        let _ = app.holidayTick
        let days = CalendarManager.monthGrid(
            for: app.currentMonth, weekStartsOnMonday: app.weekStartsOnMonday)

        VStack(spacing: 4) {
            // 星期表头
            HStack(spacing: 0) {
                ForEach(Array(CalendarManager.weekdaySymbols(weekStartsOnMonday: app.weekStartsOnMonday).enumerated()), id: \.offset) { index, symbol in
                    Text(symbol)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(index == 0 || index == 6 ? Color(nsColor: .systemRed).opacity(0.8) : Color.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 日期网格（滑动切换月份）
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(days) { info in
                    DayCellView(
                        info: info,
                        isSelected: Calendar.current.isDate(info.date, inSameDayAs: app.selectedDate),
                        showsEventDot: app.showEvents && app.eventStore.hasEvent(on: info.date),
                        showLunar: app.showLunar,
                        showFestival: app.showFestival,
                        showBadge: app.showHolidayBadge
                    )
                    .onTapGesture { app.select(info.date) }
                }
            }
        }
        .padding(.horizontal, 12)
        .highPriorityGesture(monthSwipe)
    }

    /// 左右滑动翻月（拖拽结束时判定方向）
    private var monthSwipe: some Gesture {
        DragGesture(minimumDistance: 25)
            .onEnded { value in
                let horizontal = value.translation.width
                guard abs(horizontal) > abs(value.translation.height) else { return }
                if horizontal < 0 {
                    app.move(byMonths: 1)
                } else {
                    app.move(byMonths: -1)
                }
            }
    }
}
