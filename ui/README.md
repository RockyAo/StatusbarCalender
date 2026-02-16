# UI 设计文档索引

欢迎查阅 StatusBarCalendar 的完整 UI 设计文档。

---

## 📚 文档结构

本文件夹包含了 macOS 状态栏日历应用的完整设计规范：

### 1. [设计规范 (design-spec.md)](./design-spec.md)
**核心设计文档** - 完整的设计原则和规范

- 📐 设计原则
- 状态栏显示 (Menu Bar Item)
- 主日历面板 (Main Popover)
- 设置界面 (Settings Window)
- 🎨 颜色系统
- 🎬 交互动效
- ♿️ 无障碍支持

**适用于**：产品设计师、UI/UX 设计师、项目经理

---

### 2. [组件详细规范 (component-specs.md)](./component-specs.md)
**组件库设计** - 每个 UI 组件的详细实现规范

- 📦 组件库结构
- StatusBarView - 状态栏视图
- CalendarPopover - 日历弹出面板
- CalendarHeader - 日历头部
- CalendarGrid - 日历网格
- DateCell - 日期单元格
- HolidayBadge - 节假日标记
- SettingsWindow - 设置窗口
- ⚡ 性能优化建议

**适用于**：前端开发者、组件库开发者

---

### 3. [视觉设计 (visual-design.md)](./visual-design.md)
**视觉资源** - 界面布局的可视化设计稿

- 📱 状态栏显示方案 (4种模式)
- 📅 日历面板完整布局
- 🎨 日期单元格状态展示
- ⚙️ 设置窗口布局
- 🎨 颜色板 (浅色/深色模式)
- 📏 尺寸规范表
- 🖼️ 图标资源 (SF Symbols)
- 🎭 交互状态流程图

**适用于**：视觉设计师、开发者参考

---

### 4. [交互设计规范 (interaction-design.md)](./interaction-design.md)
**交互逻辑** - 详细的用户交互设计

- 🖱️ 交互模式
- ⌨️ 键盘快捷键
- 🎬 动画规范
- 📱 手势支持 (触控板)
- 🔔 反馈机制
- 🎯 焦点管理
- 🔄 状态转换
- ♿️ 无障碍交互

**适用于**：交互设计师、前端开发者

---

### 5. [实现指南 (implementation-guide.md)](./implementation-guide.md)
**技术实现** - SwiftUI 代码示例和最佳实践

- 🏗️ 项目结构建议
- 📝 核心代码示例
  - App 入口点
  - 状态栏管理
  - 日历视图组件
  - 毛玻璃效果
  - 农历转换服务
  - 节假日服务
- 🎨 SwiftUI 技巧
- 📦 依赖库建议
- 🔧 调试技巧

**适用于**：iOS/macOS 开发者

---

## 🎯 快速开始指南

### 对于设计师

1. **了解设计理念** → 阅读 [design-spec.md](./design-spec.md)
2. **查看视觉效果** → 查阅 [visual-design.md](./visual-design.md)
3. **理解交互流程** → 参考 [interaction-design.md](./interaction-design.md)

### 对于开发者

1. **理解整体架构** → 阅读 [design-spec.md](./design-spec.md)
2. **学习组件设计** → 查阅 [component-specs.md](./component-specs.md)
3. **参考代码实现** → 使用 [implementation-guide.md](./implementation-guide.md)
4. **查看交互逻辑** → 参考 [interaction-design.md](./interaction-design.md)

### 对于产品经理

1. **了解产品定位** → 阅读 [design-spec.md](./design-spec.md) 的设计原则
2. **评估功能范围** → 查看各文档中的功能模块
3. **理解用户体验** → 参考 [interaction-design.md](./interaction-design.md)

---

## 🎨 设计亮点

### 1. 原生感设计
- 遵循 macOS Human Interface Guidelines
- 使用系统原生字体 SF Pro
- 使用 SF Symbols 图标
- 毛玻璃 (Vibrancy) 效果
- 完美支持浅色/深色模式

### 2. 高密度信息展示
- 状态栏支持 4 种显示模式
- 日历网格整合农历、节气、节假日
- 合理的信息层级和视觉权重

### 3. 优雅的交互体验
- Spring 动画效果
- 微妙的 Hover 反馈
- 完善的键盘快捷键
- 触控板手势支持

### 4. 完善的无障碍支持
- VoiceOver 支持
- 键盘完全访问
- 对比度自适应
- 动态字体支持

---

## 📐 核心尺寸速查

| 元素 | 尺寸 |
|------|------|
| **弹出面板** | 320 × 380 pt |
| **日期单元格** | 40 × 48 pt |
| **Header** | 320 × 44 pt |
| **Footer** | 320 × 40 pt |
| **星期表头** | 320 × 24 pt |
| **日历网格** | 288 × 288 pt |
| **设置窗口** | 480 × 540 pt |

---

## 🎨 颜色速查

### 功能颜色

| 用途 | 浅色模式 | 深色模式 |
|------|----------|----------|
| 休息日 | `#FF3B30` | `#FF453A` |
| 补班日 | `#007AFF` | `#0A84FF` |
| 节气 | `#FF9500` | `#FF9F0A` |
| 当前日期 | 系统强调色 | 系统强调色 |

---

## ⌨️ 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `⌘⌥C` | 显示/隐藏日历 |
| `⌘,` | 打开设置 |
| `←` `→` | 切换月份 |
| `T` | 回到今天 |
| `ESC` | 关闭面板 |

---

## 📋 开发检查清单

在实现时，请确保：

- [ ] 所有文本使用 SF Pro 字体
- [ ] 所有图标使用 SF Symbols
- [ ] 支持浅色/深色模式自动切换
- [ ] 所有颜色使用语义色彩
- [ ] 动画时长符合规范 (0.15-0.3s)
- [ ] 支持 VoiceOver 无障碍访问
- [ ] 响应键盘快捷键
- [ ] 面板在屏幕边缘正常显示
- [ ] 状态栏刷新性能优化
- [ ] 农历计算准确
- [ ] 节假日数据及时更新

---

## 🔗 相关资源

### Apple 官方文档
- [macOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

### 开发工具
- [Xcode](https://developer.apple.com/xcode/)
- [SF Symbols App](https://developer.apple.com/sf-symbols/)
- [Sketch](https://www.sketch.com/) / [Figma](https://www.figma.com/)

---

## 📊 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2024-10-24 | 初始版本，完整设计规范 |

---

## 💡 反馈与贡献

如果您在使用这些设计文档时有任何疑问或建议，欢迎：

- 提交 Issue
- 提交 Pull Request
- 联系设计团队

---

## 📝 许可证

本设计文档遵循项目主许可证。

---

**设计团队**
**最后更新**：2024-10-24
