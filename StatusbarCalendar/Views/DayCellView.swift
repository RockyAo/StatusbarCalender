import SwiftUI

/// 单个日期格子：公历日 + 农历/节日副标签 + 休/班角标 + 事件圆点
///
/// 样式设计（相比 TinyCal 的调整）：
/// - 今日用圆角胶囊高亮（原版为圆圈）
/// - 法定假日/调休补班用右上角"休/班"小角标（原版仅用颜色区分）
/// - 悬停有淡背景反馈
struct DayCellView: View {
    let info: DayInfo
    let isSelected: Bool
    var showsEventDot = false
    var showLunar = true
    var showFestival = true
    var showBadge = true

    @State private var isHovering = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 1.5) {
            Text("\(info.day)")
                .font(.system(size: 14, weight: info.isToday ? .semibold : .regular))
                .foregroundStyle(dayColor.opacity(info.isInMonth ? 1 : 0.3))
            Text(subLabel)
                .font(.system(size: 10, weight: isRedDay ? .medium : .regular))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .foregroundStyle(subColor.opacity(info.isInMonth ? 1 : 0.3))
        }
        .frame(maxWidth: .infinity, minHeight: 40)
        .background(background)
        .overlay(alignment: .topTrailing) { badge }
        .overlay(alignment: .bottom) { eventDot }
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }

    // MARK: - 副标签：节日(开) > 农历 > 空白占位

    private var subLabel: String {
        if !info.isInMonth { return "" }
        if showFestival, let festival = info.festivalName { return festival }
        if showLunar { return info.lunarLabel }
        return ""
    }

    // MARK: - 颜色（systemRed/systemOrange 随深浅色外观自适应）

    private var dayColor: Color {
        if info.isToday { return .white }
        if isRedDay { return Color(nsColor: .systemRed) }
        if info.isWeekend { return Color(nsColor: .systemRed).opacity(0.7) }
        return .primary
    }

    private var subColor: Color {
        if info.isToday { return .white.opacity(0.9) }
        if isRedDay { return Color(nsColor: .systemRed) }
        if info.kind == .swappedWorkday { return Color(nsColor: .systemOrange) }
        return .secondary
    }

    private var isRedDay: Bool { info.isFestival || info.kind == .statutoryOff }

    // MARK: - 背景 / 角标 / 事件点

    @ViewBuilder
    private var background: some View {
        let capsule = RoundedRectangle(cornerRadius: 8, style: .continuous)
        if info.isToday {
            capsule.fill(Color.accentColor)
        } else if isSelected && info.isInMonth {
            capsule.fill(Color.accentColor.opacity(0.18))
                .overlay(capsule.strokeBorder(Color.accentColor.opacity(0.5), lineWidth: 1))
        } else if isHovering && info.isInMonth {
            capsule.fill(Color.primary.opacity(colorScheme == .dark ? 0.12 : 0.07))
        }
    }

    @ViewBuilder
    private var badge: some View {
        if showBadge, info.isInMonth, info.kind != .normal {
            Text(info.kind == .statutoryOff ? "休" : "班")
                .font(.system(size: 7.5, weight: .medium))
                .foregroundStyle(.white)
                .padding(.horizontal, 2.5)
                .frame(height: 10)
                .background(Capsule().fill(
                    info.kind == .statutoryOff ? Color(nsColor: .systemGreen) : Color(nsColor: .systemOrange)
                ))
                .offset(x: 1)
        }
    }

    @ViewBuilder
    private var eventDot: some View {
        if showsEventDot, info.isInMonth {
            Circle()
                .fill(info.isToday ? Color.white : Color.accentColor.opacity(0.85))
                .frame(width: 3.5, height: 3.5)
                .offset(y: 2)
        }
    }
}
