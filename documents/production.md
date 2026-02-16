太棒了！开发一个 macOS 原生状态栏应用（Menu Bar App）是一个非常经典且实用的切入点。macOS 用户非常看重**简洁、高效和系统集成感**。

下面我为你起草了一份详细的产品文档（PRD）和技术文档。

---

## 🎯 快速开始 - 查看原型

**原型已完成！** 在开始 macOS 原生应用开发之前，可以先体验完整的交互原型：

```bash
# 1. 进入原型目录
cd prototype

# 2. 安装依赖（首次运行需要）
npm install

# 3. 启动开发服务器
npm run dev

# 4. 浏览器访问 http://localhost:5173
```

**原型功能清单**：
- ✅ 状态栏实时显示（日期、时间、星期、农历）
- ✅ 日历弹窗（月视图、节假日、节气）
- ✅ 黄历信息（宜忌、冲煞、五行）
- ✅ 完整设置面板
- ✅ 流畅动画效果

**Figma 设计稿**: https://www.figma.com/design/Xelvq0vahTNFiGxxGv4nqh/日历应用

---

## 一、 产品需求文档 (PRD)

### 1. 项目概述

这款应用旨在为 macOS 用户提供一个高度可定制的状态栏日历工具，填补系统自带日历在显示阴历、节假日及调休信息方面的空白。

### 2. 核心功能

* **状态栏自定义显示**：支持阴历、周几、24/12小时制、秒显。
* **悬浮/点击预览**：鼠标触发后展示完整日历面板。
* **中国农历与节假日**：集成中国特有的法定节假日及调休补班逻辑。

### 3. 功能详细说明

| 功能模块 | 需求描述 | 备注 |
| --- | --- | --- |
| **状态栏配置** | 用户可自由组合：`[日期] [阴历] [星期] [时间]`。 | 提供格式预览。 |
| **时间显示** | 1. 支持 24h/12h 切换；2. 支持 AM/PM 标识；3. 秒针开关。 | 实时刷新频率控制。 |
| **日历面板** | 显示当前月视图，突出显示周末、法定节假日（红点）和补班（班字）。 | 类似系统通知中心风格。 |
| **数据同步** | 自动获取每年国务院公布的放假安排。 | 需支持离线缓存。 |

### 4. UI/UX 设计建议

* **交互逻辑**：虽然你提到“停留（Hover）”，但在 macOS 规范中，点击（Click）触发 Popover 更符合用户习惯。建议支持“点击打开，停留预览（可选）”。
* **视觉风格**：适配 macOS 的深色/浅色模式，使用 `Visual Effect View` 实现毛玻璃效果。

---

## 二、 技术方案文档

### 1. 技术栈选择

#### 原型技术栈（已实现）

* **核心框架**
  - React 18 - 现代化 UI 框架
  - TypeScript - 类型安全开发
  - Vite - 快速构建工具

* **样式方案**
  - Tailwind CSS - 原子化 CSS 框架
  - PostCSS - CSS 处理

* **UI 组件库**
  - Radix UI - 无样式可访问组件（Accordion, Dialog, Select 等）
  - Material-UI - Material Design 组件
  - Lucide React - 现代图标库

* **动画库**
  - Motion (Framer Motion) - 流畅的过渡动画
  - 支持进入/退出动画
  - 支持手势控制

* **工具库**
  - lunar-javascript - 专业的农历计算库
  - date-fns - 日期处理工具
  - clsx - 类名管理

* **开发工具**
  - ESLint - 代码规范
  - TypeScript Compiler - 类型检查

#### macOS 应用技术栈（规划）

* **语言**：Swift 5.x
* **框架**：**SwiftUI** (界面) + **AppKit** (系统状态栏管理)
* **系统要求**：macOS 12.0+

### 2. 核心架构设计

#### 原型架构（Web）

原型使用现代前端架构：

* **组件化设计**: 每个功能模块独立封装
  - `MenuBar`: 状态栏显示组件
  - `CalendarPopover`: 日历弹窗主容器
  - `HuangliSection`: 黄历信息展示
  - `SettingsDialog`: 设置对话框
  - `HolidayLegend`: 节假日图例说明

* **工具函数库**: 可复用的核心逻辑
  - `lunar.ts`: 农历计算（基于 lunar-javascript）
  - `holidays.ts`: 节假日数据管理
  - `huangli.ts`: 黄历算法实现

* **状态管理**: React Hooks（useState, useEffect）
  - 集中管理显示设置
  - 日期选择状态
  - 弹窗显示状态

* **样式方案**: Tailwind CSS 工具类
  - 响应式设计
  - 主题变量
  - 自定义动画

#### macOS 应用架构（规划）

应用将采用典型的 **MVVM 架构**：

* **Model**: 处理日期计算、农历转换算法、节假日 JSON 解析。
* **ViewModel**: 负责状态栏字符串的格式化逻辑、倒计时刷新。
* **View**: 使用 `NSPopover` 承载 SwiftUI 编写的日历视图。

### 3. 关键技术实现点

#### A. 状态栏管理 (`NSStatusItem`)

在 macOS 中，状态栏应用不使用传统的 `Window`。

```swift
// 伪代码示例
let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

func updateStatusBar() {
    if let button = statusItem.button {
        button.title = "10月24日 周四 农历九月廿二 14:00:05"
        // 添加 TrackingArea 实现悬浮监听
    }
}

```

#### B. 悬浮展开逻辑

由于状态栏按钮默认不响应 `mouseEntered`，你需要子类化 `NSStatusBarButton` 或添加 `NSTrackingArea` 来捕获鼠标停留事件，从而弹出 `NSPopover`。

#### C. 中国农历与节假日数据

* **农历计算**：推荐使用 Swift 原生的 `Calendar(identifier: .chinese)`，它可以直接处理大部分农历转换逻辑。
* **节假日与调休**：建议内置一个 `holidays.json` 文件，并提供远程更新机制（如同步 GitHub 上的开源节假日数据集），因为调休日期每年都会变。

#### D. 性能优化

* **刷新率控制**：如果不显示“秒”，UI 刷新频率应限制在每分钟一次；如果显示“秒”，需开启 `Timer` 每一秒刷新一次，注意能耗。

---

## 三、 实施计划 (Roadmap)

### ✅ 已完成 - 原型阶段

**原型目录**: `prototype/`

已使用 React + TypeScript 实现完整可交互原型，包括：

1. **状态栏组件** (`MenuBar.tsx`)
   - ✅ 实时显示日期、星期、农历、时间
   - ✅ 支持悬停/点击触发
   - ✅ 自定义显示格式（24/12小时制、显示秒等）
   - ✅ 毛玻璃背景效果

2. **日历弹窗** (`CalendarPopover.tsx`)
   - ✅ 月历视图，支持前后月份导航
   - ✅ 今日高亮显示
   - ✅ 农历日期、节气标注
   - ✅ 法定节假日红点标记
---

### 原型的技术亮点

1. **完整的组件封装**
   - 每个组件职责单一，易于维护
   - Props 接口清晰，类型安全
   - 组合式设计，灵活复用

2. **优秀的用户体验**
   - 毛玻璃效果（backdrop-blur-2xl）
   - 流畅的动画过渡
   - 响应式交互反馈
   - 点击外部区域自动关闭

3. **数据驱动**
   - 状态集中管理
   - 自动响应数据变化
   - 本地存储用户设置

4. **可扩展性**
   - 易于添加新的显示模块
   - 工具函数独立，便于测试
   - 支持自定义主题

5. **性能优化**
   - React.memo 减少重渲染
   - 事件委托优化
   - 懒加载组件

---

### 从原型到 macOS 应用的迁移要点

原型已经验证了完整的交互设计和功能逻辑，迁移到 SwiftUI 时需要注意：

1. **状态管理**
   - React useState → SwiftUI @State
   - React useEffect → SwiftUI .onAppear / .onChange

2. **组件结构**
   - React 组件 → SwiftUI View
   - Props → View 参数
   - CSS 类 → SwiftUI 修饰符

3. **动画系统**
   - Motion → SwiftUI Animation
   - AnimatePresence → transition + if 条件

4. **数据持久化**
   - localStorage → UserDefaults
   - 设置面板逻辑可直接迁移

5. **农历计算**
   - lunar-javascript 逻辑 → Swift Calendar.chinese
   - 或直接移植 JavaScript 算法到 Swift

---

   - ✅ 调休补班橙点标记
   - ✅ 周末日期特殊颜色

3. **黄历功能** (`HuangliSection.tsx`)
   - ✅ 显示天干地支、生肖
   - ✅ 五行、建除信息
   - ✅ 冲煞提示
   - ✅ 宜忌事项列表
   - ✅ 可通过设置开关控制

4. **设置面板** (`SettingsDialog.tsx`)
   - ✅ 状态栏内容自定义
   - ✅ 时间格式选择
   - ✅ 日历显示选项
   - ✅ 交互方式配置（悬停/点击）
   - ✅ 黄历功能开关

5. **核心工具函数**
   - ✅ 农历计算 (`utils/lunar.ts`)
   - ✅ 节假日数据 (`utils/holidays.ts`)
   - ✅ 黄历算法 (`utils/huangli.ts`)

6. **视觉与动画**
   - ✅ 毛玻璃效果（backdrop-blur）
   - ✅ 流畅的进入/退出动画
   - ✅ 状态栏悬停反馈
   - ✅ 响应式设计

**原型文件结构**：
```
prototype/
├── src/
│   ├── app/
│   │   ├── components/          # 组件目录
│   │   │   ├── MenuBar.tsx      # 状态栏组件
│   │   │   ├── CalendarPopover.tsx  # 日历弹窗
│   │   │   ├── HuangliSection.tsx   # 黄历模块
│   │   │   ├── SettingsDialog.tsx   # 设置对话框
│   │   │   ├── HolidayLegend.tsx    # 图例说明
│   │   │   └── ui/              # 基础 UI 组件 (Radix)
│   │   ├── utils/               # 工具函数
│   │   │   ├── lunar.ts         # 农历计算
│   │   │   ├── holidays.ts      # 节假日数据
│   │   │   └── huangli.ts       # 黄历算法
│   │   └── App.tsx              # 应用主入口
│   ├── styles/                  # 样式文件
│   │   ├── tailwind.css         # Tailwind 配置
│   │   └── index.css            # 全局样式
│   └── main.tsx                 # React 入口
├── package.json                 # 依赖配置
├── vite.config.ts               # Vite 配置
└── README.md                    # 说明文档
```

**原型演示地址**: http://localhost:5173 （需运行 `npm run dev`）

**Figma 设计稿**: https://www.figma.com/design/Xelvq0vahTNFiGxxGv4nqh/日历应用

### 🔜 下一步 - macOS 原生应用开发

1. **Phase 1**: 基于原型，使用 SwiftUI 实现状态栏显示
   - 将 Web 组件逻辑迁移到 SwiftUI
   - 集成 NSStatusItem 实现真实状态栏
   - 使用 Swift 原生 Calendar 处理农历

2. **Phase 2**: 开发日历面板 UI
   - 使用 NSPopover 承载 SwiftUI 视图
   - 实现原型中的日历网格布局
   - 添加鼠标悬停和点击交互

3. **Phase 3**: 集成数据与功能
   - 注入节假日 JSON 数据
   - 实现黄历算法移植
   - 添加本地数据缓存

4. **Phase 4**: 性能优化与系统集成
   - 优化内存占用与 CPU 唤醒频率
   - 适配多屏显示
   - 支持系统深色模式自动切换
   - 添加偏好设置持久化

