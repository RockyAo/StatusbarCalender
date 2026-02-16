# StatusbarCalendar

一个基于 SwiftUI 的 macOS 菜单栏时钟应用，使用 Swift 6 规范。

## 功能特性

- ✅ 在菜单栏显示当前时间
- ✅ 支持切换显示/隐藏秒
- ✅ 使用 Swift 6 的 @Observable 宏实现状态管理
- ✅ 现代化的 SwiftUI 界面

## 技术栈

- Swift 6.0+
- SwiftUI
- macOS 14.0+
- Observation Framework (@Observable)

## 项目结构

```
StatusbarCalendar/
├── StatusbarCalendarApp.swift   # 应用入口
├── ClockManager.swift            # 时钟管理器（使用 @Observable）
├── MenuBarView.swift             # 菜单栏弹出视图
└── SettingsView.swift            # 设置界面
```

## 核心实现

### ClockManager

使用 Swift 6 的 `@Observable` 宏实现响应式状态管理：

- `showSeconds: Bool` - 控制是否显示秒
- `currentTimeString: String` - 当前时间字符串
- 自动管理定时器，根据是否显示秒调整更新频率（1秒/60秒）

### 状态管理

- 使用 `@Observable` 替代传统的 `ObservableObject`
- 使用 `@Bindable` 实现双向绑定
- 完全符合 Swift 6 的并发模型

## 如何构建

### 使用 Xcode

1. 打开 Xcode
2. File > New > Project
3. 选择 macOS > App
4. 复制本目录中的所有 Swift 文件到项目中
5. 运行项目

### 使用 Swift Package Manager

```bash
# 在项目根目录
swift build
swift run
```

## 使用方法

1. 启动应用后，时钟会出现在菜单栏
2. 点击菜单栏时钟图标可以查看详细信息
3. 点击"设置"按钮可以切换是否显示秒
4. 点击"退出"按钮关闭应用

## 开发说明

### Swift 6 新特性使用

- **@Observable 宏**: 简化状态管理，自动生成观察代码
- **@Bindable**: 用于在视图中创建双向绑定
- **严格并发检查**: 确保线程安全的状态访问

### 自定义扩展

你可以轻松扩展此应用：

1. 在 `ClockManager` 中添加更多时间格式选项
2. 在 `MenuBarView` 中添加日历视图
3. 添加农历、节日等功能
4. 支持主题切换

## License

MIT
