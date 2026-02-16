# 组件详细规范

本文档详细定义各个 UI 组件的实现细节，供开发参考。

---

## 📦 组件库结构

```
Components/
├── MenuBar/
│   └── StatusBarView.swift          # 状态栏显示
├── Popover/
│   ├── CalendarPopover.swift        # 主弹出面板
│   ├── CalendarHeader.swift         # 头部导航
│   ├── CalendarGrid.swift           # 日历网格
│   ├── DateCell.swift               # 日期单元格
│   └── CalendarFooter.swift         # 底部信息
├── Settings/
│   ├── SettingsWindow.swift         # 设置窗口
│   ├── DisplayTab.swift             # 显示设置
│   ├── TimeTab.swift                # 时间设置
│   ├── StyleTab.swift               # 样式设置
│   └── HolidayTab.swift             # 节假日设置
└── Shared/
    ├── LunarDateView.swift          # 农历显示
    ├── HolidayBadge.swift           # 节假日标记
    └── NavigationButton.swift       # 导航按钮
```

---

## 1. StatusBarView (状态栏视图)

### 功能描述
显示在 macOS 菜单栏的主视图，作为应用入口

### Props / 参数

```swift
struct StatusBarViewConfig {
    var showDate: Bool = true           // 显示日期
    var showWeekday: Bool = true        // 显示星期
    var showLunar: Bool = true          // 显示农历
    var showSeconds: Bool = false       // 显示秒数
    var use24Hour: Bool = true          // 24小时制
}
```

### 状态管理

```swift
@State private var currentDate: Date = Date()
@State private var isHovered: Bool = false
```

### 布局实现

```
┌────────────────────────────────────────┐
│ 10月24日 周四 农历九月廿二 14:00:05   │
│ ↑        ↑     ↑            ↑        │
│ date  weekday lunar        time      │
└────────────────────────────────────────┘
```

### 代码示例

```swift
HStack(spacing: 4) {
    if config.showDate {
        Text(dateFormatter.string(from: currentDate))
    }
    
    if config.showWeekday {
        Text(weekdayFormatter.string(from: currentDate))
    }
    
    if config.showLunar {
        Text(lunarDateString)
            .foregroundColor(.secondary)
    }
    
    Text(timeFormatter.string(from: currentDate))
        .monospacedDigit() // 等宽数字，防止数字跳动
}
.padding(.horizontal, 8)
.padding(.vertical, 3)
.background(
    RoundedRectangle(cornerRadius: 6)
        .fill(isHovered ? Color.gray.opacity(0.15) : Color.clear)
)
.onHover { hovering in
    isHovered = hovering
}
```

### 刷新机制

```swift
.onAppear {
    // 根据是否显示秒数决定刷新频率
    let interval = config.showSeconds ? 1.0 : 60.0
    Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
        currentDate = Date()
    }
}
```

---

## 2. CalendarPopover (日历弹出面板)

### 功能描述
点击状态栏后弹出的主日历面板

### 尺寸规范

```swift
let popoverWidth: CGFloat = 320
let popoverHeight: CGFloat = 380
```

### 布局结构

```swift
VStack(spacing: 0) {
    CalendarHeader(selectedDate: $selectedDate)
        .frame(height: 44)
    
    Divider()
    
    WeekdayHeader()
        .frame(height: 24)
    
    CalendarGrid(
        selectedDate: $selectedDate,
        holidays: holidays
    )
    .frame(height: 288) // 6行 × 48pt
    
    Divider()
    
    CalendarFooter(date: selectedDate)
        .frame(height: 40)
}
.frame(width: popoverWidth, height: popoverHeight)
.background(VisualEffectBlur())
```

### 毛玻璃效果

```swift
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .popover
        view.blendingMode = .behindWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
```

---

## 3. CalendarHeader (日历头部)

### 功能描述
显示年月信息和导航按钮

### 布局代码

```swift
HStack {
    // 年月选择器
    Button(action: { showYearMonthPicker.toggle() }) {
        Text("\(year)年 \(month)月")
            .font(.system(size: 18, weight: .semibold))
    }
    .buttonStyle(.plain)
    
    Spacer()
    
    // 导航按钮组
    HStack(spacing: 4) {
        NavigationButton(icon: "chevron.left") {
            selectedDate = Calendar.current.date(
                byAdding: .month, 
                value: -1, 
                to: selectedDate
            )!
        }
        
        NavigationButton(icon: "arrow.uturn.backward") {
            selectedDate = Date() // 回到今天
        }
        
        NavigationButton(icon: "chevron.right") {
            selectedDate = Calendar.current.date(
                byAdding: .month, 
                value: 1, 
                to: selectedDate
            )!
        }
    }
}
.padding(.horizontal, 16)
.padding(.vertical, 8)
```

### NavigationButton 组件

```swift
struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isHovered ? Color.gray.opacity(0.15) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}
```

---

## 4. WeekdayHeader (星期表头)

### 布局实现

```swift
HStack(spacing: 2) {
    ForEach(weekdaySymbols, id: \.self) { weekday in
        Text(weekday)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(
                isWeekend(weekday) ? .red.opacity(0.6) : .secondary
            )
            .frame(width: 40)
    }
}
.padding(.horizontal, 16)
```

### 数据源

```swift
let weekdaySymbols = ["一", "二", "三", "四", "五", "六", "日"]

func isWeekend(_ weekday: String) -> Bool {
    return weekday == "六" || weekday == "日"
}
```

---

## 5. CalendarGrid (日历网格)

### 核心逻辑

```swift
struct CalendarGrid: View {
    @Binding var selectedDate: Date
    let holidays: [Date: Holiday]
    
    // 计算当月的日历矩阵 (6周 × 7天)
    private var calendarDays: [[Date?]] {
        generateCalendarMatrix(for: selectedDate)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<6) { week in
                HStack(spacing: 2) {
                    ForEach(0..<7) { day in
                        if let date = calendarDays[week][day] {
                            DateCell(
                                date: date,
                                isCurrentMonth: isInCurrentMonth(date),
                                isToday: isToday(date),
                                holiday: holidays[date]
                            )
                        } else {
                            Color.clear.frame(width: 40, height: 48)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}
```

### 日历矩阵生成算法

```swift
func generateCalendarMatrix(for date: Date) -> [[Date?]] {
    let calendar = Calendar.current
    var matrix: [[Date?]] = []
    
    // 获取当月第一天
    let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
    
    // 获取第一天是星期几 (0=周日, 1=周一, ...)
    let firstWeekday = calendar.component(.weekday, from: firstDay)
    let offset = (firstWeekday + 5) % 7 // 转换为周一开始
    
    // 填充6周
    for week in 0..<6 {
        var weekDays: [Date?] = []
        for day in 0..<7 {
            let dayOffset = week * 7 + day - offset
            if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDay) {
                weekDays.append(date)
            } else {
                weekDays.append(nil)
            }
        }
        matrix.append(weekDays)
    }
    
    return matrix
}
```

---

## 6. DateCell (日期单元格)

### 完整实现

```swift
struct DateCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let holiday: Holiday?
    
    @State private var isHovered = false
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                // 日期数字
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.system(
                        size: 15, 
                        weight: isToday ? .semibold : .regular
                    ))
                    .foregroundColor(dateColor())
                
                // 节假日标记
                if let holiday = holiday {
                    HolidayBadge(type: holiday.type)
                        .offset(x: 12, y: -8)
                }
            }
            
            // 农历/节气
            Text(lunarText())
                .font(.system(size: 9))
                .foregroundColor(.tertiary)
                .lineLimit(1)
        }
        .frame(width: 40, height: 48)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(backgroundColor())
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onHover { isHovered = $0 }
    }
    
    // MARK: - Helpers
    
    func dateColor() -> Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.4)
        }
        if isWeekend(date) {
            return .red.opacity(0.7)
        }
        return .primary
    }
    
    func backgroundColor() -> Color {
        if isHovered {
            return Color.gray.opacity(0.1)
        }
        return Color.clear
    }
    
    func lunarText() -> String {
        // 返回农历日期或节气
        let lunar = LunarCalendar.convert(date)
        return lunar.solarTerm ?? lunar.dayString
    }
}
```

---

## 7. HolidayBadge (节假日标记)

### 设计方案

```swift
enum HolidayType {
    case rest      // 休息日
    case workday   // 补班日
}

struct HolidayBadge: View {
    let type: HolidayType
    
    var body: some View {
        Text(badgeText)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 14, height: 14)
            .background(
                Circle().fill(badgeColor)
            )
    }
    
    var badgeText: String {
        switch type {
        case .rest: return "休"
        case .workday: return "班"
        }
    }
    
    var badgeColor: Color {
        switch type {
        case .rest: return .red
        case .workday: return .blue
        }
    }
}
```

### 备选方案：圆点标记

```swift
struct HolidayDot: View {
    let type: HolidayType
    
    var body: some View {
        Circle()
            .fill(type == .rest ? Color.red : Color.blue)
            .frame(width: 6, height: 6)
    }
}
```

---

## 8. CalendarFooter (底部信息栏)

### 实现代码

```swift
struct CalendarFooter: View {
    let date: Date
    @State private var settingsHovered = false
    
    var body: some View {
        HStack {
            // 农历详细信息
            Text(detailedLunarInfo)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
            
            Spacer()
            
            // 设置按钮
            Button(action: openSettings) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(settingsHovered ? 45 : 0))
                    .animation(.easeInOut(duration: 0.2), value: settingsHovered)
            }
            .buttonStyle(.plain)
            .onHover { settingsHovered = $0 }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
    
    var detailedLunarInfo: String {
        let lunar = LunarCalendar.convert(date)
        return "\(lunar.yearString) \(lunar.monthString)\(lunar.dayString)"
        // 示例：甲辰龙年 九月廿二
    }
    
    func openSettings() {
        // 打开设置窗口
        SettingsWindow.show()
    }
}
```

---

## 9. SettingsWindow (设置窗口)

### TabView 结构

```swift
struct SettingsWindow: View {
    var body: some View {
        TabView {
            DisplayTab()
                .tabItem {
                    Label("显示", systemImage: "eye")
                }
                .tag(0)
            
            TimeTab()
                .tabItem {
                    Label("时间", systemImage: "clock")
                }
                .tag(1)
            
            StyleTab()
                .tabItem {
                    Label("样式", systemImage: "paintbrush")
                }
                .tag(2)
            
            HolidayTab()
                .tabItem {
                    Label("节假日", systemImage: "calendar.badge.clock")
                }
                .tag(3)
            
            AboutTab()
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(4)
        }
        .frame(width: 480, height: 540)
    }
}
```

### DisplayTab (显示设置)

```swift
struct DisplayTab: View {
    @AppStorage("showDate") private var showDate = true
    @AppStorage("showWeekday") private var showWeekday = true
    @AppStorage("showLunar") private var showLunar = true
    @AppStorage("showSeconds") private var showSeconds = false
    
    var body: some View {
        Form {
            Section("状态栏内容") {
                Toggle("显示日期", isOn: $showDate)
                Toggle("显示星期", isOn: $showWeekday)
                Toggle("显示农历", isOn: $showLunar)
                Toggle("显示秒数", isOn: $showSeconds)
            }
            
            Section("农历显示格式") {
                Picker("", selection: $lunarFormat) {
                    Text("完整格式").tag(LunarFormat.full)
                    Text("简化格式").tag(LunarFormat.simplified)
                    Text("仅日期").tag(LunarFormat.dateOnly)
                }
                .pickerStyle(.radioGroup)
            }
        }
        .padding()
    }
}
```

---

## 10. 动画效果实现

### 面板弹出动画

```swift
.transition(
    .asymmetric(
        insertion: .move(edge: .top).combined(with: .opacity),
        removal: .opacity
    )
)
.animation(.spring(response: 0.25, dampingFraction: 0.8), value: isPopoverPresented)
```

### 月份切换动画

```swift
.transition(
    .asymmetric(
        insertion: .move(edge: direction == .forward ? .trailing : .leading),
        removal: .move(edge: direction == .forward ? .leading : .trailing)
    )
)
.animation(.easeInOut(duration: 0.3), value: currentMonth)
```

### Hover 动画

```swift
.scaleEffect(isHovered ? 1.05 : 1.0)
.animation(.easeInOut(duration: 0.15), value: isHovered)
```

---

## 📐 间距系统

### 统一间距变量

```swift
enum Spacing {
    static let xs: CGFloat = 2
    static let sm: CGFloat = 4
    static let md: CGFloat = 8
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
}
```

### 使用示例

```swift
VStack(spacing: Spacing.md) {
    // ...
}
.padding(.horizontal, Spacing.lg)
```

---

## 🎨 颜色系统

### 语义色定义

```swift
extension Color {
    static let dateCellText = Color.primary
    static let dateCellSecondary = Color.secondary
    static let dateCellTertiary = Color(.tertiaryLabelColor)
    
    static let holidayRest = Color.red
    static let holidayWork = Color.blue
    static let solarTerm = Color.orange
    
    static let hoverBackground = Color.gray.opacity(0.1)
    static let dividerColor = Color(.separatorColor)
}
```

---

## ⚡ 性能优化建议

### 1. 使用 LazyVStack 优化大列表

```swift
// 如果设置项很多，使用 LazyVStack
ScrollView {
    LazyVStack {
        // 设置项
    }
}
```

### 2. 日历数据缓存

```swift
class CalendarCache {
    private var cache: [String: [[Date?]]] = [:]
    
    func getMatrix(for date: Date) -> [[Date?]] {
        let key = "\(date.year)-\(date.month)"
        if let cached = cache[key] {
            return cached
        }
        let matrix = generateCalendarMatrix(for: date)
        cache[key] = matrix
        return matrix
    }
}
```

### 3. 农历计算优化

```swift
// 使用 lazy 计算属性
var lunarDate: LunarDate {
    get {
        LunarCalendar.convert(date)
    }
}
```

---

**文档版本**：v1.0
**最后更新**：2024-10-24
