# StatusbarCalendar - 日历视图实现说明

## ✅ 已完成功能

### 1. 核心组件

#### 📅 日历网格视图 (CalendarGridView)
- 使用 `LazyVGrid` 实现 7 列布局（周一到周日）
- 自动计算并显示每月所有日期（包括前后月份的溢出日期）
- 月份切换功能（上一月/下一月）
- "回到今天" 快捷按钮
- 毛玻璃背景效果（`.ultraThinMaterial`）

#### 🗓 日期单元格 (DayCell)
- **日期数字**: 显示当天的阳历日期
- **农历文字**: 显示对应的农历（初一显示月份，其他显示日期）
- **今日高亮**: 使用系统强调色边框和背景标记今天
- **节假日角标**: 
  - "休" - 红色角标（法定节假日）
  - "班" - 蓝色角标（调休补班）
- **非当月日期**: 降低透明度显示
- **符合 Figma 设计**: 圆角、间距、字体大小严格对应

#### 🌙 农历计算引擎 (LunarCalendar)
- 基于 Apple 原生 `Calendar(identifier: .chinese)`
- 完整的农历日期转换（年、月、日）
- 支持闰月识别
- 传统农历命名（正月、二月...腊月；初一、初二...三十）

#### 🎛 日历管理器 (CalendarManager)
- 使用 Swift 6 的 `@Observable` 宏
- `@MainActor` 确保线程安全
- 月份导航逻辑
- 日期信息自动计算

### 2. 数据模型

```swift
DayInfo: 日期信息模型
├── date: Date               // 具体日期
├── day: Int                 // 日期数字
├── isCurrentMonth: Bool     // 是否当前月
├── isToday: Bool           // 是否今天
├── lunarText: String       // 农历文字
├── status: DayStatus       // 节假日状态
└── holidayName: String?    // 节日名称

DayStatus: 节假日状态枚举
├── holiday  // 休息日
├── workday  // 调休补班
└── normal   // 普通日
```

### 3. 视觉设计特性

✅ 符合 Figma 设计规范:
- 圆角: 12px (面板) / 6px (单元格)
- 毛玻璃效果: `.ultraThinMaterial`
- 字体:
  - 月份标题: 16pt, Semibold
  - 日期数字: 14pt (今日加粗)
  - 农历文字: 9pt, Secondary 色
  - 角标文字: 8pt, Medium
- 间距: 4pt (单元格) / 12pt (面板)
- 颜色: 
  - 今日: 系统强调色
  - 休息日角标: 红色 0.8
  - 补班角标: 蓝色 0.7

### 4. Swift 6 特性

✅ 完全符合 Swift 6 严格并发模型:
- `@Observable` 替代 `ObservableObject`
- `@MainActor` 保证 UI 线程安全
- `Sendable` 协议确保数据安全传递
- 无 `Combine` 依赖，使用原生 Swift 并发

## 🎯 使用方法

### 在 Xcode 中运行

1. 打开项目:
   ```bash
   cd projects/macos
   open StatusbarCalendar.xcodeproj
   ```

2. 选择 scheme: `StatusbarCalendar`

3. 运行 (⌘R)

4. 点击菜单栏时钟图标查看日历面板

### 项目结构

```
StatusbarCalendar/
├── StatusbarCalendarApp.swift   # App 入口
├── ClockManager.swift            # 时钟管理
├── CalendarManager.swift         # 日历管理 (@Observable)
├── LunarCalendar.swift          # 农历计算工具
├── DayStatus.swift              # 数据模型定义
├── MenuBarView.swift            # 菜单栏主视图
├── CalendarGridView.swift       # 日历网格
├── DayCell.swift                # 日期单元格
└── SettingsView.swift           # 设置界面
```

## 📸 功能演示

### 日历面板包含:
1. **顶部信息栏**: 当前日期、农历信息、实时时间
2. **月份导航**: 上一月 / 下一月切换
3. **星期标题**: 日一二三四五六
4. **日期网格**: 7x6 布局，展示完整月视图
5. **底部操作**: "回到今天" 和系统菜单

### 日期单元格展示:
- **阳历日期** (大字)
- **农历信息** (小字，灰色)
- **今日标记** (强调色边框)
- **节假日角标** (右上角 "休" 或 "班")

## 🔜 下一步开发 (Step 3)

根据技术文档 `tech.md`，下一步将实现:

1. **HolidayService**: 节假日数据服务
   - 本地 JSON 数据内置
   - GitHub 异步更新
   - 缓存机制

2. **节假日数据集成**:
   - 自动标记法定节假日
   - 调休补班日标记
   - 节日名称显示

3. **性能优化**:
   - 日期计算缓存
   - 视图复用优化

## 🎨 Figma 设计参考

设计稿地址: https://cactus-axis-25725963.figma.site

当前实现已严格遵循:
- ✅ 布局尺寸
- ✅ 圆角规范
- ✅ 颜色方案
- ✅ 字体层级
- ✅ 间距系统
- ✅ 毛玻璃效果

## 🐛 已知问题

无 - 当前版本稳定运行

## 📝 技术亮点

1. **纯 Swift 原生**: 无第三方依赖
2. **农历支持**: Apple 原生 API，无需额外数据库
3. **类型安全**: Swift 6 严格并发检查通过
4. **声明式 UI**: 100% SwiftUI 实现
5. **高性能**: LazyVGrid 按需渲染
6. **可扩展**: 模块化设计，易于添加新功能
