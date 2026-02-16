# 快速开始指南

## 🚀 快速启动 (推荐)

### 方法 1: 打开 Xcode 项目

```bash
cd /Users/yun.ao/Documents/github/StatusbarCalender/projects/macos
open StatusbarCalendar.xcodeproj
```

在 Xcode 中：
1. 选择 StatusbarCalendar scheme
2. 选择 "My Mac" 作为目标设备
3. 点击运行按钮 (⌘R)
4. 应用将在菜单栏显示时间 🎉

### 方法 2: 双击打开

直接在 Finder 中双击 `StatusbarCalendar.xcodeproj` 文件，然后按 ⌘R 运行。

## 📝 备选方式: 使用 Xcode 创建新项目

1. 打开 Xcode
2. File > New > Project
3. 选择 macOS > App
4. 项目配置：
   - Product Name: StatusbarCalendar
   - Interface: SwiftUI
   - Language: Swift
   - 取消勾选 "Use Core Data"
5. 将以下文件复制到项目中：
   - StatusbarCalendarApp.swift
   - ClockManager.swift
   - MenuBarView.swift
   - SettingsView.swift
6. 在项目设置中：
   - Deployment Target: macOS 14.0 或更高
   - Swift Language Version: Swift 6

## 方法 3: 命令行构建 (开发测试)

```bash
cd /Users/yun.ao/Documents/github/StatusbarCalender/projects/macos
swift build
swift run
```

注意：使用命令行运行时菜单栏功能可能受限，建议使用 Xcode 运行。

## 项目配置要点

### Info.plist 关键设置

`LSUIElement` 设置为 `true` 可以隐藏 Dock 图标，使应用仅在菜单栏显示。

### Swift 6 语言模式

项目使用 Swift 6 的严格并发模式，确保：
- 使用 `@Observable` 而非 `ObservableObject`
- 使用 `@Bindable` 进行双向绑定
- Timer 正确运行在主线程

## 故障排除

### 如果菜单栏不显示

确保在 Info.plist 中 `LSUIElement` 设置正确。

### 如果编译错误

- 确认 macOS 部署目标 >= 14.0
- 确认 Swift 版本 >= 6.0
- 确认已导入 Observation framework

### 如果时间不更新

检查 ClockManager 中的 Timer 是否正确添加到 RunLoop。
