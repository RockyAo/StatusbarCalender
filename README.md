# 状态栏日历 macOS 应用

一个 macOS 状态栏日历应用，提供农历与节假日信息，已完成核心日历与节假日数据能力。

## ✨ 当前进度（macOS 原生）

### 已实现

- 🗓️ **完整日历视图** - 月历显示，支持上一月/下一月、回到今天
- 🌙 **农历支持** - 基于 `Calendar.chinese` 的农历日期显示
- 🎉 **法定节假日** - 休/班角标、按年份自动拉取并缓存
- 💾 **本地持久化** - SQLite 存储节假日数据
- 💠 **Swift 6 并发** - `@Observable` + `@MainActor`
- 🧊 **毛玻璃面板** - `.ultraThinMaterial` 视觉风格

### 待完善

- 状态栏显示内容自定义（日期/农历/星期/时间）
- 12/24 小时制与 AM/PM
- 鼠标悬停触发（当前为点击触发）
- 节气/传统节日与黄历信息

## 🎨 可交互原型（Web）

在 [prototype 文件夹](./prototype/) 中提供了完整的网页原型：

```bash
cd prototype
npm install
npm run dev
```

原型展示了完整的交互体验和视觉设计，包括：
- ✅ 状态栏实时显示（日期、时间、星期、农历）
- ✅ 日历弹窗界面（月视图、节气、节假日）
- ✅ 黄历信息（宜忌、冲煞、五行）
- ✅ 完整的设置面板（自定义显示选项）
- ✅ 流畅的动画效果
- ✅ 毛玻璃质感设计

**技术栈**: React + TypeScript + Vite + Tailwind CSS + Motion

## 🚀 快速开始

### 运行 macOS 应用

```bash
cd projects/macos
open StatusbarCalendar.xcodeproj
```

在 Xcode 中：
1. 选择 **StatusbarCalendar** scheme
2. 选择 **My Mac** 作为目标设备
3. 按 `⌘R` 运行

### 查看原型演示

```bash
# 1. 进入原型目录
cd prototype

# 2. 安装依赖
npm install

# 3. 启动开发服务器
npm run dev

# 4. 浏览器访问 http://localhost:5173
```

### macOS 应用说明

目前已完成核心日历、农历与节假日数据链路，详见实现文档：
- [documents/IMPLEMENTATION.md](documents/IMPLEMENTATION.md)
- [documents/TODO.md](documents/TODO.md)

## 📸 预览

### 设计参考与原型

原型展示了完整的交互设计和视觉效果：

**状态栏组件**
- 实时更新的日期、时间、星期、农历
- 悬停时的视觉反馈
- 可自定义显示格式（24/12小时制、是否显示秒等）

**日历弹窗**
- 完整的月历视图，清晰的日期网格
- 今日用系统蓝色高亮
- 周末日期红色显示
- 节假日用红点标记
- 调休补班用橙点标记
- 节气用绿色文字显示
- 底部图例说明

**黄历信息**
- 天干地支、生肖、五行
- 建除、冲煞
- 宜忌事项分类展示

**设置面板**
- 状态栏内容自定义
- 时间格式选择
- 日历显示选项
- 交互方式配置

> 运行原型查看完整效果：`cd prototype && npm run dev`

## 🛠️ 技术栈

### 原型演示（Web）

- **语言**: TypeScript
- **框架**: React 18
- **构建工具**: Vite
- **样式**: Tailwind CSS
- **UI 组件**: Radix UI + Material-UI
- **动画**: Motion (Framer Motion)
- **农历**: lunar-javascript

### macOS 应用（当前）

- **语言**: Swift 6+
- **框架**: SwiftUI, AppKit
- **最低系统**: macOS 12.0+
- **开发工具**: Xcode 26+

## 📝 开发进度

- [x] 基础框架搭建
- [x] 日历核心功能
- [x] 农历支持
- [x] 节假日功能（含缓存）
- [x] 状态栏内容自定义
- [x] 时间格式选项（12/24h）
- [ ] 鼠标悬停交互
- [ ] 节气/传统节日/黄历
- [x] 设置界面完善

查看详细的[开发路线图](documents/TODO.md)

## 🤝 贡献

欢迎贡献！请查看设计文档了解项目规范。

## 📄 许可证

MIT License

---

**版本**: v0.1.0 (开发中)  
**最后更新**: 2026-2-17