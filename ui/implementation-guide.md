# SwiftUI 实现参考

本文档提供关键组件的 SwiftUI 代码实现示例，供开发参考。

---

## 🏗️ 项目结构建议

```
StatusBarCalendar/
├── App/
│   ├── StatusBarCalendarApp.swift    # App 入口
│   ├── AppDelegate.swift              # 状态栏管理
│   └── MenuBarManager.swift           # 菜单栏控制器
│
├── Views/
│   ├── MenuBar/
│   │   └── StatusBarView.swift
│   │
│   ├── Calendar/
│   │   ├── CalendarPopover.swift
│   │   ├── CalendarHeader.swift
│   │   ├── WeekdayHeader.swift
│   │   ├── CalendarGrid.swift
│   │   ├── DateCell.swift
│   │   └── CalendarFooter.swift
│   │
│   ├── Settings/
│   │   ├── SettingsWindow.swift
│   │   ├── DisplaySettingsView.swift
│   │   ├── TimeSettingsView.swift
│   │   ├── StyleSettingsView.swift
│   │   ├── HolidaySettingsView.swift
│   │   └── AboutView.swift
│   │
│   └── Components/
│       ├── HolidayBadge.swift
│       ├── NavigationButton.swift
│       └── VisualEffectBlur.swift
│
├── Models/
│   ├── CalendarDate.swift
│   ├── LunarDate.swift
│   ├── Holiday.swift
│   └── AppSettings.swift
│
├── ViewModels/
│   ├── CalendarViewModel.swift
│   ├── StatusBarViewModel.swift
│   └── SettingsViewModel.swift
│
├── Services/
│   ├── LunarCalendarService.swift
│   ├── HolidayService.swift
│   └── DateFormatterService.swift
│
├── Utilities/
│   ├── Extensions/
│   │   ├── Date+Extensions.swift
│   │   ├── Color+Extensions.swift
│   │   └── Calendar+Extensions.swift
│   │
│   └── Constants/
│       ├── DesignSystem.swift
│       └── AppConstants.swift
│
└── Resources/
    ├── Assets.xcassets
    ├── Localizable.strings
    └── holidays.json
```

---

## 📝 核心代码示例

### 1. App 入口点

```swift
// StatusBarCalendarApp.swift

import SwiftUI

@main
struct StatusBarCalendarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // 设置窗口
        Settings {
            SettingsWindow()
        }
    }
}
```

---

### 2. AppDelegate (状态栏管理)

```swift
// AppDelegate.swift

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // 创建状态栏项目
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // 配置按钮
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
            
            // 使用 SwiftUI View 作为内容
            let statusBarView = StatusBarView()
            let hostingView = NSHostingView(rootView: statusBarView)
            hostingView.frame = NSRect(x: 0, y: 0, width: 200, height: 22)
            button.addSubview(hostingView)
        }
        
        // 创建 Popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 380)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: CalendarPopover()
        )
        
        // 监听点击外部区域
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover()
            }
        }
    }
    
    @objc func togglePopover() {
        if popover.isShown {
            closePopover()
        } else {
            showPopover()
        }
    }
    
    func showPopover() {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            eventMonitor?.start()
        }
    }
    
    func closePopover() {
        popover.performClose(nil)
        eventMonitor?.stop()
    }
}
```

---

### 3. 事件监听器 (点击外部关闭)

```swift
// EventMonitor.swift

import Cocoa

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
```

---

### 4. 状态栏视图

```swift
// StatusBarView.swift

import SwiftUI

struct StatusBarView: View {
    @StateObject private var viewModel = StatusBarViewModel()
    @AppStorage("showDate") private var showDate = true
    @AppStorage("showWeekday") private var showWeekday = true
    @AppStorage("showLunar") private var showLunar = true
    @AppStorage("showSeconds") private var showSeconds = false
    
    var body: some View {
        HStack(spacing: 4) {
            if showDate {
                Text(viewModel.dateString)
            }
            
            if showWeekday {
                Text(viewModel.weekdayString)
            }
            
            if showLunar {
                Text(viewModel.lunarString)
                    .foregroundColor(.secondary)
            }
            
            Text(viewModel.timeString)
                .monospacedDigit()
        }
        .font(.system(size: 13))
        .padding(.horizontal, 8)
        .onAppear {
            viewModel.startTimer(showSeconds: showSeconds)
        }
    }
}
```

---

### 5. 状态栏 ViewModel

```swift
// StatusBarViewModel.swift

import Foundation
import Combine

class StatusBarViewModel: ObservableObject {
    @Published var currentDate = Date()
    
    private var timer: AnyCancellable?
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter.string(from: currentDate)
    }
    
    var weekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        let weekday = formatter.string(from: currentDate)
        return weekday.replacingOccurrences(of: "星期", with: "周")
    }
    
    var lunarString: String {
        let lunar = LunarCalendarService.shared.convert(currentDate)
        return "农历\(lunar.monthString)\(lunar.dayString)"
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: currentDate)
    }
    
    func startTimer(showSeconds: Bool) {
        let interval: TimeInterval = showSeconds ? 1.0 : 60.0
        
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.currentDate = Date()
            }
    }
}
```

---

### 6. 日历弹出面板

```swift
// CalendarPopover.swift

import SwiftUI

struct CalendarPopover: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            CalendarHeader(
                selectedDate: $viewModel.selectedDate,
                onPreviousMonth: viewModel.previousMonth,
                onNextMonth: viewModel.nextMonth,
                onToday: viewModel.goToToday
            )
            .frame(height: 44)
            
            Divider()
            
            // 星期表头
            WeekdayHeader()
                .frame(height: 24)
            
            // 日历网格
            CalendarGrid(
                selectedDate: $viewModel.selectedDate,
                calendarDays: viewModel.calendarDays,
                holidays: viewModel.holidays
            )
            .frame(height: 288)
            
            Divider()
            
            // Footer
            CalendarFooter(date: viewModel.selectedDate)
                .frame(height: 40)
        }
        .frame(width: 320, height: 380)
        .background(VisualEffectBlur())
    }
}
```

---

### 7. 日历 ViewModel

```swift
// CalendarViewModel.swift

import Foundation
import Combine

class CalendarViewModel: ObservableObject {
    @Published var selectedDate = Date()
    @Published var holidays: [Date: Holiday] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadHolidays()
        
        // 监听日期变化
        $selectedDate
            .sink { [weak self] _ in
                self?.generateCalendarDays()
            }
            .store(in: &cancellables)
    }
    
    var calendarDays: [[Date?]] {
        generateCalendarMatrix(for: selectedDate)
    }
    
    func previousMonth() {
        selectedDate = Calendar.current.date(
            byAdding: .month,
            value: -1,
            to: selectedDate
        ) ?? selectedDate
    }
    
    func nextMonth() {
        selectedDate = Calendar.current.date(
            byAdding: .month,
            value: 1,
            to: selectedDate
        ) ?? selectedDate
    }
    
    func goToToday() {
        selectedDate = Date()
    }
    
    private func generateCalendarMatrix(for date: Date) -> [[Date?]] {
        let calendar = Calendar.current
        var matrix: [[Date?]] = []
        
        // 获取当月第一天
        guard let firstDay = calendar.date(
            from: calendar.dateComponents([.year, .month], from: date)
        ) else {
            return []
        }
        
        // 计算第一天是星期几
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offset = (firstWeekday + 5) % 7 // 转换为周一开始
        
        // 生成 6 周的日期
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
    
    private func generateCalendarDays() {
        // 触发更新
        objectWillChange.send()
    }
    
    private func loadHolidays() {
        // 从本地或网络加载节假日数据
        HolidayService.shared.loadHolidays { [weak self] holidays in
            self?.holidays = holidays
        }
    }
}
```

---

### 8. 日历头部

```swift
// CalendarHeader.swift

import SwiftUI

struct CalendarHeader: View {
    @Binding var selectedDate: Date
    let onPreviousMonth: () -> Void
    let onNextMonth: () -> Void
    let onToday: () -> Void
    
    @State private var showYearMonthPicker = false
    
    private var yearMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        HStack {
            // 年月选择器
            Button(action: { showYearMonthPicker.toggle() }) {
                Text(yearMonthString)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // 导航按钮
            HStack(spacing: 4) {
                NavigationButton(icon: "chevron.left", action: onPreviousMonth)
                NavigationButton(icon: "arrow.uturn.backward", action: onToday)
                NavigationButton(icon: "chevron.right", action: onNextMonth)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
```

---

### 9. 导航按钮

```swift
// NavigationButton.swift

import SwiftUI

struct NavigationButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.primary)
                .frame(width: 28, height: 28)
                .background(
                    Circle()
                        .fill(isHovered ? Color.gray.opacity(0.15) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}
```

---

### 10. 星期表头

```swift
// WeekdayHeader.swift

import SwiftUI

struct WeekdayHeader: View {
    private let weekdays = ["一", "二", "三", "四", "五", "六", "日"]
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(weekdays, id: \.self) { weekday in
                Text(weekday)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isWeekend(weekday) ? .red.opacity(0.6) : .secondary)
                    .frame(width: 40)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func isWeekend(_ weekday: String) -> Bool {
        weekday == "六" || weekday == "日"
    }
}
```

---

### 11. 日历网格

```swift
// CalendarGrid.swift

import SwiftUI

struct CalendarGrid: View {
    @Binding var selectedDate: Date
    let calendarDays: [[Date?]]
    let holidays: [Date: Holiday]
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<6, id: \.self) { week in
                HStack(spacing: 2) {
                    ForEach(0..<7, id: \.self) { day in
                        if let date = calendarDays[week][day] {
                            DateCell(
                                date: date,
                                isCurrentMonth: isInCurrentMonth(date),
                                isToday: isToday(date),
                                holiday: holidays[normalizeDate(date)]
                            )
                        } else {
                            Color.clear
                                .frame(width: 40, height: 48)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    private func isInCurrentMonth(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func normalizeDate(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }
}
```

---

### 12. 日期单元格

```swift
// DateCell.swift

import SwiftUI

struct DateCell: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let holiday: Holiday?
    
    @State private var isHovered = false
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                // 日期数字
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(
                        size: 15,
                        weight: isToday ? .semibold : .regular
                    ))
                    .foregroundColor(dateColor)
                
                // 节假日标记
                if let holiday = holiday {
                    HolidayBadge(type: holiday.type)
                        .offset(x: 12, y: -8)
                }
            }
            
            // 农历/节气
            Text(lunarText)
                .font(.system(size: 9))
                .foregroundColor(.tertiary)
                .lineLimit(1)
        }
        .frame(width: 40, height: 48)
        .background(backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .strokeBorder(isToday ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.12)) {
                isHovered = hovering
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var dateColor: Color {
        if !isCurrentMonth {
            return .secondary.opacity(0.4)
        }
        if isWeekend {
            return .red.opacity(0.7)
        }
        return .primary
    }
    
    private var backgroundColor: Color {
        isHovered ? Color.gray.opacity(0.1) : Color.clear
    }
    
    private var lunarText: String {
        let lunar = LunarCalendarService.shared.convert(date)
        return lunar.solarTerm ?? lunar.dayString
    }
    
    private var isWeekend: Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
}
```

---

### 13. 节假日标记

```swift
// HolidayBadge.swift

import SwiftUI

enum HolidayType {
    case rest     // 休息日
    case workday  // 补班日
}

struct Holiday {
    let date: Date
    let type: HolidayType
    let name: String
}

struct HolidayBadge: View {
    let type: HolidayType
    
    var body: some View {
        Text(badgeText)
            .font(.system(size: 9, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 14, height: 14)
            .background(Circle().fill(badgeColor))
    }
    
    private var badgeText: String {
        type == .rest ? "休" : "班"
    }
    
    private var badgeColor: Color {
        type == .rest ? .red : .blue
    }
}
```

---

### 14. 毛玻璃效果

```swift
// VisualEffectBlur.swift

import SwiftUI

struct VisualEffectBlur: NSViewRepresentable {
    var material: NSVisualEffectView.Material = .popover
    var blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
```

---

### 15. 农历转换服务

```swift
// LunarCalendarService.swift

import Foundation

struct LunarDate {
    let year: Int
    let month: Int
    let day: Int
    let isLeapMonth: Bool
    
    var yearString: String {
        // 甲辰龙年
        let heavenlyStem = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
        let earthlyBranch = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
        let zodiac = ["鼠", "牛", "虎", "兔", "龙", "蛇", "马", "羊", "猴", "鸡", "狗", "猪"]
        
        let stemIndex = (year - 4) % 10
        let branchIndex = (year - 4) % 12
        
        return "\(heavenlyStem[stemIndex])\(earthlyBranch[branchIndex])\(zodiac[branchIndex])年"
    }
    
    var monthString: String {
        let months = ["正月", "二月", "三月", "四月", "五月", "六月",
                     "七月", "八月", "九月", "十月", "冬月", "腊月"]
        let prefix = isLeapMonth ? "闰" : ""
        return prefix + months[month - 1]
    }
    
    var dayString: String {
        let days = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                   "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                   "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
        return days[day - 1]
    }
    
    var solarTerm: String? {
        // 返回节气（如果有）
        // 这里需要实现节气计算算法
        return nil
    }
}

class LunarCalendarService {
    static let shared = LunarCalendarService()
    
    func convert(_ date: Date) -> LunarDate {
        // 这里需要实现完整的农历转换算法
        // 可以使用第三方库或自己实现
        
        // 示例返回值
        return LunarDate(year: 2024, month: 9, day: 22, isLeapMonth: false)
    }
}
```

---

### 16. 节假日服务

```swift
// HolidayService.swift

import Foundation

class HolidayService {
    static let shared = HolidayService()
    
    func loadHolidays(completion: @escaping ([Date: Holiday]) -> Void) {
        // 从本地 JSON 或远程 API 加载节假日数据
        
        guard let url = Bundle.main.url(forResource: "holidays", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONDecoder().decode([HolidayData].self, from: data) else {
            completion([:])
            return
        }
        
        var holidays: [Date: Holiday] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for item in json {
            if let date = dateFormatter.date(from: item.date) {
                let normalizedDate = Calendar.current.startOfDay(for: date)
                holidays[normalizedDate] = Holiday(
                    date: normalizedDate,
                    type: item.type == "rest" ? .rest : .workday,
                    name: item.name
                )
            }
        }
        
        completion(holidays)
    }
}

struct HolidayData: Codable {
    let date: String
    let name: String
    let type: String
}
```

---

### 17. 设计系统常量

```swift
// DesignSystem.swift

import SwiftUI

enum DesignSystem {
    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 2
        static let sm: CGFloat = 4
        static let md: CGFloat = 8
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
    }
    
    // MARK: - Corner Radius
    enum CornerRadius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 6
        static let large: CGFloat = 12
    }
    
    // MARK: - Font Size
    enum FontSize {
        static let largeTitle: CGFloat = 18
        static let title: CGFloat = 16
        static let dateNumber: CGFloat = 15
        static let body: CGFloat = 13
        static let detail: CGFloat = 12
        static let weekday: CGFloat = 11
        static let lunar: CGFloat = 9
    }
    
    // MARK: - Animation Duration
    enum AnimationDuration {
        static let fast: TimeInterval = 0.15
        static let normal: TimeInterval = 0.25
        static let slow: TimeInterval = 0.3
    }
}
```

---

### 18. App 设置 (UserDefaults)

```swift
// AppSettings.swift

import Foundation
import Combine

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var showDate = true {
        didSet { UserDefaults.standard.set(showDate, forKey: "showDate") }
    }
    
    @Published var showWeekday = true {
        didSet { UserDefaults.standard.set(showWeekday, forKey: "showWeekday") }
    }
    
    @Published var showLunar = true {
        didSet { UserDefaults.standard.set(showLunar, forKey: "showLunar") }
    }
    
    @Published var showSeconds = false {
        didSet { UserDefaults.standard.set(showSeconds, forKey: "showSeconds") }
    }
    
    @Published var use24Hour = true {
        didSet { UserDefaults.standard.set(use24Hour, forKey: "use24Hour") }
    }
    
    @Published var launchAtLogin = false {
        didSet { 
            UserDefaults.standard.set(launchAtLogin, forKey: "launchAtLogin")
            configureLaunchAtLogin(launchAtLogin)
        }
    }
    
    private init() {
        loadSettings()
    }
    
    private func loadSettings() {
        showDate = UserDefaults.standard.bool(forKey: "showDate")
        showWeekday = UserDefaults.standard.bool(forKey: "showWeekday")
        showLunar = UserDefaults.standard.bool(forKey: "showLunar")
        showSeconds = UserDefaults.standard.bool(forKey: "showSeconds")
        use24Hour = UserDefaults.standard.bool(forKey: "use24Hour")
        launchAtLogin = UserDefaults.standard.bool(forKey: "launchAtLogin")
    }
    
    private func configureLaunchAtLogin(_ enabled: Bool) {
        // 配置开机自启动
        // 使用 ServiceManagement 框架
    }
}
```

---

## 🎨 SwiftUI 技巧

### 1. 自定义修饰符

```swift
// 日期单元格悬停效果
struct HoverEffect: ViewModifier {
    @State private var isHovered = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovered ? 1.05 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .onHover { hovering in
                isHovered = hovering
            }
    }
}

extension View {
    func hoverEffect() -> some View {
        modifier(HoverEffect())
    }
}

// 使用
Text("Hello")
    .hoverEffect()
```

---

### 2. 自适应颜色

```swift
extension Color {
    static let adaptiveBackground = Color(NSColor.windowBackgroundColor)
    static let adaptiveText = Color(NSColor.labelColor)
    static let adaptiveSecondary = Color(NSColor.secondaryLabelColor)
}
```

---

### 3. 安全区域适配

```swift
.edgesIgnoringSafeArea(.all)
.background(VisualEffectBlur().edgesIgnoringSafeArea(.all))
```

---

## 📦 依赖库建议

### Podfile / Package.swift

```swift
// Swift Package Manager

dependencies: [
    // 农历库
    .package(url: "https://github.com/isee15/Lunar-Swift", from: "1.0.0"),
    
    // 日期扩展
    .package(url: "https://github.com/malcommac/SwiftDate", from: "7.0.0"),
]
```

---

## 🔧 调试技巧

### 1. 查看视图层级

```swift
.overlay(
    GeometryReader { geometry in
        Text("\(Int(geometry.size.width)) x \(Int(geometry.size.height))")
            .font(.caption)
            .foregroundColor(.red)
    }
)
```

### 2. 性能监测

```swift
.onAppear {
    let start = CFAbsoluteTimeGetCurrent()
    // 执行操作
    let diff = CFAbsoluteTimeGetCurrent() - start
    print("⏱ Render time: \(diff)")
}
```

---

**文档版本**：v1.0
**最后更新**：2024-10-24
