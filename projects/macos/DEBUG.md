# StatusbarCalendar 调试指南

## ✅ 已完成的配置

1. **Info.plist** - LSUIElement 已设置为 `true`
   - 应用将隐藏 Dock 图标，只在菜单栏显示

2. **StatusbarCalendarApp.swift** - 添加了调试日志
   - 启动时打印 Bundle ID 和 LSUIElement 状态
   - MenuBarExtra 显示时打印确认信息

3. **MenuBarExtra Style** - 设置为 `.window` 模式
   - 确保点击后弹出窗口而不是菜单

## 🚀 运行步骤

### 方法一：使用调试脚本

```bash
cd /Users/yun.ao/Documents/github/StatusbarCalender/projects/macos
./debug.sh
```

然后在 Xcode 中：
1. 按 `⌘⇧K` 清理构建文件夹
2. 按 `⌘B` 构建项目
3. 按 `⌘R` 运行应用

### 方法二：手动操作

1. **清理缓存**
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData/StatusbarCalendar-*
   ```

2. **在 Xcode 中**
   - Product → Clean Build Folder (`⌘⇧K`)
   - Product → Build (`⌘B`)
   - Product → Run (`⌘R`)

## 🔍 验证成功标志

运行成功后你应该看到：

1. **Xcode 控制台输出**
   ```
   🚀 StatusbarCalendar App launching...
   📍 Bundle ID: com.example.StatusbarCalendar
   📍 LSUIElement: true
   ✅ MenuBarExtra label appeared: 14:30:45
   ```

2. **macOS 菜单栏**
   - 右上角出现时间文本（如 "14:30:45"）
   - 点击后弹出日历面板

3. **Dock**
   - 应用图标**不应该**出现在 Dock 中

## ❌ 常见问题排查

### 问题 1: 菜单栏看不到图标

**可能原因：**
- 应用崩溃或未启动
- 系统权限问题
- Xcode 缓存问题

**解决方法：**
```bash
# 1. 完全退出应用
killall StatusbarCalendar

# 2. 清理所有缓存
rm -rf ~/Library/Developer/Xcode/DerivedData/StatusbarCalendar-*
rm -rf ~/Library/Caches/com.example.StatusbarCalendar

# 3. 重新构建
```

### 问题 2: 应用启动后立即退出

**检查：**
- 查看 Xcode 控制台是否有崩溃日志
- 确认所有依赖文件都存在
- 验证 Swift 版本为 6.0

### 问题 3: 点击菜单栏无反应

**检查：**
- `.menuBarExtraStyle(.window)` 是否正确设置
- `MenuBarView` 是否有布局错误
- 面板宽度是否过大（当前设置 380px）

### 问题 4: 时间不更新

**检查：**
- `ClockManager` 的定时器是否启动
- 在 Xcode 控制台看是否有更新日志

## 📊 调试技巧

### 查看详细日志

在 [StatusbarCalendarApp.swift](StatusbarCalendar/StatusbarCalendarApp.swift) 中已添加调试日志。

如需更多日志，可以在 [ClockManager.swift](StatusbarCalendar/ClockManager.swift) 的 `updateTime()` 中添加：

```swift
private func updateTime() {
    print("⏰ Updating time: \(currentTimeString)")
    // ... existing code
}
```

### 检查菜单栏项状态

在运行时，可以在 Xcode 调试器中查看：
```
po clockManager.currentTimeString
po calendarManager.currentDate
```

### 强制显示面板

如果需要测试面板显示，可以临时修改触发方式：
- 当前：点击触发
- 可选：添加键盘快捷键或鼠标悬停

## 🎯 下一步开发

当前已完成：
- ✅ Step 1: 基础菜单栏框架
- ✅ Step 2: 日历 UI 静态布局

待完成：
- ⏳ Step 3: HolidayService（节假日数据）
- ⏳ Step 4: 鼠标悬停触发（NSTrackingArea）

## 📞 需要帮助？

如果问题仍然存在，请提供：
1. Xcode 控制台的完整输出
2. macOS 版本号
3. 是否有任何错误或警告信息
