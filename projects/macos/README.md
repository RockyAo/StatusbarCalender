# StatusbarCalendar

一款深度集成于 macOS 状态栏的轻量级日历应用，完美支持中国农历，使用 Swift 6 和 SwiftUI 构建。

## ✨ 功能特性

### 已实现 ✅

- **菜单栏时钟**: 在状态栏实时显示时间，支持切换显示/隐藏秒
- **完整日历视图**: 
  - 7x6 网格布局，完整月视图
  - 支持月份切换和"回到今天"功能
  - 今日高亮显示（系统强调色）
- **农历支持**: 
  - 基于 Apple 原生 `Calendar.chinese`
  - 完整的农历日期转换（正月、二月...腊月）
  - 支持闰月识别
- **优雅的 UI 设计**:
  - 毛玻璃效果（Vibrant Material）
  - 符合 macOS 设计规范
  - 支持 Light/Dark 模式自动切换
  - 圆角、间距严格遵循 Figma 设计
- **Swift 6 特性**:
  - 使用 `@Observable` 宏实现状态管理
  - 完全符合严格并发模型（`@MainActor`）
  - 类型安全，无运行时错误

### 规划中 🚧

- **节假日标记**: 
  - 法定节假日 "休" 角标
  - 调休补班 "班" 角标
  - 云端数据同步
- **鼠标悬停触发**: 使用 `NSTrackingArea` 实现
- **自定义显示选项**: 状态栏显示内容可配置

## 📸 界面预览

### 日历面板包含:
1. **顶部**: 当前日期、农历信息、实时时间
2. **导航**: 上一月/下一月切换，月份年份显示
3. **星期标题**: 日一二三四五六
4. **日期网格**: 
   - 阳历日期（大字）
   - 农历信息（小字）
   - 今日标记（强调色边框）
5. **底部**: "回到今天" 快捷按钮和系统菜单

## 🛠 技术栈

- **语言**: Swift 6.0+
- **UI 框架**: SwiftUI + AppKit (MenuBarExtra)
- **最低系统**: macOS 14.0+
- **状态管理**: @Observable (Swift 6 原生)
- **并发模型**: @MainActor 严格并发检查
- **农历计算**: Apple 原生 Calendar API

## � 快速开始

### 环境要求

- macOS 14.0 或更高版本
- Xcode 15.0+ (支持 Swift 6)
- 无需额外依赖库

### 方法 1: 直接运行 (推荐)

```bash
cd /Users/yun.ao/Documents/github/StatusbarCalender/projects/macos
open StatusbarCalendar.xcodeproj
```

在 Xcode 中：
1. 选择 **StatusbarCalendar** scheme
2. 选择 **My Mac** 作为目标设备
3. 按 `⌘R` 或点击运行按钮
4. 应用将在菜单栏显示 🎉

### 方法 2: 使用 Finder

直接在 Finder 中双击 `StatusbarCalendar.xcodeproj` 文件，然后按 `⌘R` 运行。

### 首次运行

1. 应用启动后会在菜单栏显示日历图标和当前时间
2. 点击菜单栏图标即可弹出日历面板
3. 应用不会在 Dock 中显示图标（已设置 `LSUIElement = true`）

### 使用提示

- **查看日历**: 点击菜单栏图标
- **切换月份**: 使用日历顶部的左右箭头
- **回到今天**: 点击底部"回到今天"按钮
- **退出应用**: 点击底部"退出"按钮

## �📂 项目结构

```
StatusbarCalendar/
├── StatusbarCalendarApp.swift   # 应用入口 (@main)
├── ClockManager.swift            # 时钟管理器 (@Observable)
├── CalendarManager.swift         # 日历管理器 (@Observable)
├── LunarCalendar.swift          # 农历计算工具
├── DayStatus.swift              # 数据模型定义
├── MenuBarView.swift            # 菜单栏主视图
├── CalendarGridView.swift       # 日历网格 (LazyVGrid)
├── DayCell.swift                # 日期单元格组件
├── SettingsView.swift           # 设置界面
├── HolidayService.swift         # 节假日数据服务
├── HolidayModels.swift          # 节假日数据模型
├── HolidayDatabase.swift        # SQLite 数据库管理
└── Assets.xcassets/             # 资源文件
```

## 📖 详细文档

- **实现说明**: 查看 [documents/IMPLEMENTATION.md](../../documents/IMPLEMENTATION.md) 了解详细的技术实现
- **技术规约**: 查看 [documents/tech.md](../../documents/tech.md) 了解技术架构和开发规范
- **产品需求**: 查看 [documents/production.md](../../documents/production.md) 了解产品定位

## 🎯 核心实现

### ClockManager - 时钟管理

```swift
@Observable
final class ClockManager {
    var showSeconds: Bool = true
    var currentTimeString: String = ""
    
    // 智能定时器：显示秒时 1s 更新，否则 60s 更新
    private var timer: Timer?
}
```

### CalendarManager - 日历管理

```swift
@Observable @MainActor
final class CalendarManager {
    var currentDate: Date = Date()
    var selectedMonth: Date = Date()
    
    // 自动计算当月所有日期（包括溢出）
    func daysInMonth() -> [DayInfo]
}
```

### LunarCalendar - 农历计算

```swift
struct LunarCalendar {
    private let chineseCalendar: Calendar
    
    // 转换为农历字符串：初一显示月份，其他显示日期
    func lunarDateString(from date: Date) -> String
}
```

### DayCell - 日期单元格

- 显示阳历日期和农历文字
- 今日高亮（强调色边框和背景）
- 节假日角标（"休"/"班"）
- 非当月日期透明度降低

## 📋 开发进度

- [x] Step 1: 基础菜单栏应用框架
- [x] Step 2: 日历 UI 和农历支持
- [ ] Step 3: 节假日数据集成
- [ ] Step 4: 鼠标悬停交互增强

详见 [IMPLEMENTATION.md](IMPLEMENTATION.md) 了解详细实现。

## 📐 设计规范

基于 Figma 设计: https://cactus-axis-25725963.figma.site

### 尺寸
- 面板宽度: 280pt
- 单元格高度: 44pt
- 圆角: 12pt (面板) / 6pt (单元格)

### 字体
- 月份标题: 16pt Semibold
- 日期数字: 14pt (今日 Semibold)
- 农历文字: 9pt
- 角标文字: 8pt Medium

### 间距
- 单元格间距: 4pt
- 面板内边距: 12pt

### 颜色
- 今日: 系统强调色
- 休息日: Red 0.8
- 补班日: Blue 0.7
- 背景: Ultra Thin Material

## 🔧 配置说明

### Info.plist 关键设置

- `LSUIElement` = `true`: 隐藏 Dock 图标，仅显示菜单栏
- `LSMinimumSystemVersion` = `14.0`: 最低系统要求

### Swift 6 并发设置

```swift
SWIFT_STRICT_CONCURRENCY = complete
SWIFT_VERSION = 6.0
```

## 📝 使用的 Swift 6 特性

1. **@Observable 宏**: 替代 ObservableObject
2. **@Bindable**: 双向绑定
3. **@MainActor**: UI 线程安全
4. **Sendable 协议**: 跨并发域数据安全
5. **严格并发检查**: 完全类型安全

## 🎨 Figma 设计参考

当前实现已严格遵循 Figma 设计:
- ✅ 布局尺寸
- ✅ 圆角规范
- ✅ 颜色方案
- ✅ 字体层级
- ✅ 间距系统
- ✅ 毛玻璃效果

## 📄 License

MIT

---

Created with ❤️ using Swift 6 and SwiftUI
