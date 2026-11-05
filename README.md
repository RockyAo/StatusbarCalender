# StatusbarCalendar 状态栏日历

macOS 菜单栏日历：菜单栏实时显示「日期 + 农历/节日」，点击弹出月历面板，支持法定节假日休/班标记与系统日历事件。

v2.0 为 SwiftUI 重写版（原 v1 为 Objective-C/AppKit 实现）。

## 功能

- 菜单栏文字实时显示：日期 + 农历（节日优先），可在设置中切换为仅日期 / 日期+星期
- 月历面板：公历 + 农历副标签（初一显示月份名）、农历/公历/周末节日、左右滑动或箭头翻月
- 法定节假日：放假日期绿色「休」角标、调休补班日橙色「班」角标
- 系统日历事件（可选）：网格事件圆点 + 当日事件列表，基于 EventKit
- 当日详情：农历干支全称、节日、距春节天数
- 设置：周一起始、登录自启（SMAppService）、各显示项开关

## 构建与运行

```bash
open StatusbarCalendar.xcodeproj   # Xcode 16+ / macOS 14+
# 或
xcodebuild -project StatusbarCalendar.xcodeproj -scheme StatusbarCalendar build
```

无第三方依赖；农历由系统 `Calendar(identifier: .chinese)` 计算，节假日数据内置。

## 目录结构

```
StatusbarCalendar/
├── StatusbarCalendarApp.swift    # 入口：MenuBarExtra + Settings
├── AppState.swift                # 全局状态与设置（UserDefaults 持久化）
├── Models/DayInfo.swift          # 日期格子模型
├── Services/
│   ├── LunarCalendar.swift       # 农历/干支/生肖/节日规则
│   ├── HolidayDatabase.swift     # 法定节假日数据加载
│   ├── CalendarManager.swift     # 月份网格构建
│   └── EventStoreManager.swift   # EventKit 日历事件
├── Views/                        # 面板、网格、格子、事件列表、设置
└── Resources/holidays.json       # 节假日数据（可自行更新）
```

## 更新节假日数据

每年 11 月前后国务院办公厅发布次年安排后，编辑 `StatusbarCalendar/Resources/holidays.json`：

- `holidays`：放假日期（含调休连休的每一天），格式 `MM-DD`
- `workdays`：周末补班日

> 内置 2025 全年、2026 全年（2026 年劳动节/国庆的调休补班日以官方通知为准，确认后补充到 `workdays` 即可）。

## 设计说明

界面风格参考同类菜单栏日历并做了调整：今日使用圆角胶囊高亮（非圆圈）、休/班使用文字角标（非纯颜色）、悬停高亮反馈、靛蓝强调色。
