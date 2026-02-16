# StatusbarCalendar - 功能开发清单

## ✅ 已实现功能（macOS 原生应用）

### 核心功能
- ✅ **菜单栏显示**
  - 显示当前时间（HH:mm:ss 或 HH:mm）
  - 日历图标 + 时间文本
  - 点击触发弹窗
  
- ✅ **日历面板**
  - LazyVGrid 7x6 网格布局
  - 月份切换（上一月/下一月）
  - 回到今天功能
  - 今日高亮（蓝色背景 + 白色文字）
  - 非当月日期半透明显示
  
- ✅ **农历支持**
  - 基于 Apple 原生 `Calendar.chinese`
  - 完整农历转换（正月、二月...腊月）
  - 支持闰月识别
  - 初一显示月份，其他显示日期
  
- ✅ **节假日集成**
  - API: `https://date.appworlds.cn/year/{year}`
  - 红色"休"角标（法定假期）
  - 橙色"班"角标（调休补班）
  - 左上角 14px 圆形标记
  - SQLite 本地缓存
  - 按年份智能加载
  - 切换月份自动加载新年份数据
  
- ✅ **数据持久化**
  - SQLite 数据库存储
  - 数据库路径: `~/Library/Application Support/com.example.StatusbarCalendar/holidays.db`
  - 自动迁移旧表结构
  - 元数据跟踪同步状态
  
- ✅ **基础设置**
  - 显示/隐藏秒
  - 设置对话框框架

### UI/UX
- ✅ 毛玻璃效果（`.ultraThinMaterial`）
- ✅ 符合 Figma 设计（380px 宽度、16px 圆角）
- ✅ 支持深色/浅色模式
- ✅ LSUIElement = true（无 Dock 图标）

### 技术实现
- ✅ Swift 6.0 严格并发检查
- ✅ @Observable 状态管理
- ✅ @MainActor 线程安全
- ✅ SwiftUI 声明式 UI
- ✅ 无第三方依赖

---

## ❌ 未实现功能（对照产品需求文档）

### 1. 状态栏自定义显示 ⚠️ 高优先级

**需求（PRD 第 3 节）**：
> 用户可自由组合：`[日期] [阴历] [星期] [时间]`

**当前状态**：
- ❌ 仅显示时间（HH:mm:ss）
- ❌ 无法显示日期（如 "10月24日"）
- ❌ 无法显示农历（如 "农历九月廿二"）
- ❌ 无法显示星期（如 "周四"）
- ❌ 无自定义格式选择

**实现建议**：
```swift
// ClockManager 需要扩展
struct StatusBarDisplayOptions {
    var showDate: Bool = true
    var showLunar: Bool = true
    var showWeekday: Bool = true
    var showTime: Bool = true
}

// 生成示例："10月24日 农历九月廿二 周四 14:00:05"
```

---

### 2. 时间格式选项 ⚠️ 高优先级

**需求（PRD 第 3 节）**：
> 1. 支持 24h/12h 切换；2. 支持 AM/PM 标识；3. 秒针开关

**当前状态**：
- ✅ 秒针开关（已实现）
- ❌ 24/12 小时制切换
- ❌ AM/PM 标识

**实现建议**：
```swift
// ClockManager 扩展
enum TimeFormat {
    case twentyFourHour
    case twelveHour
}

var timeFormat: TimeFormat = .twentyFourHour

// 格式示例：
// 24h: "14:30:45"
// 12h: "2:30:45 PM"
```

---

### 3. 鼠标悬停触发 ⚠️ 中优先级

**需求（PRD 第 2 节 + 第 4 节）**：
> 悬浮/点击预览：鼠标触发后展示完整日历面板
> UI/UX 设计建议：支持"点击打开，停留预览（可选）"

**当前状态**：
- ✅ 点击触发（已实现）
- ❌ 鼠标悬停触发（可选）

**实现建议**：
参考 tech.md Step 4：
```swift
// 使用 NSViewRepresentable 包装透明视图
// 捕捉 mouseEntered 事件
struct HoverTrackingView: NSViewRepresentable {
    var onHoverEnter: () -> Void
    
    // 添加 NSTrackingArea
}
```

---

### 4. 黄历功能 🔵 低优先级

**需求（原型已实现，PRD 未明确）**：
Web 原型包含完整黄历功能：
- 天干地支、生肖
- 五行、建除
- 冲煞提示
- 宜忌事项列表

**当前状态**：
- ❌ 完全未实现

**实现建议**：
需要移植 `prototype/src/app/utils/huangli.ts` 算法到 Swift

---

### 5. 节气标注 🔵 低优先级

**需求（原型已实现，PRD 未明确）**：
Web 原型在日历单元格显示节气

**当前状态**：
- ✅ DayInfo 数据模型有 `isSolarTerm` 字段
- ❌ 未实现节气数据填充
- ❌ UI 未显示节气

**实现建议**：
```swift
// 需要添加节气数据源
struct SolarTerm {
    let name: String  // "立春"、"雨水"等
    let date: Date
}

// 在 DayCell 中优先显示节气名称而非农历
```

---

### 6. 传统节日标注 🔵 低优先级

**需求（原型已实现，PRD 未明确）**：
Web 原型显示传统节日（如春节、中秋节）

**当前状态**：
- ✅ DayInfo 数据模型有 `isFestival` 字段
- ❌ 未实现节日数据
- ❌ UI 未显示节日

**实现建议**：
```swift
// 添加传统节日数据
let lunarFestivals = [
    "01-01": "春节",
    "01-15": "元宵节",
    "05-05": "端午节",
    "08-15": "中秋节",
    // ...
]
```

---

### 7. 周末颜色区分 🔵 低优先级

**需求（PRD 第 3 节）**：
> 显示当前月视图，突出显示周末、法定节假日（红点）和补班（班字）

**当前状态**：
- ✅ 节假日标记（已实现）
- ❌ 周末颜色区分

**实现建议**：
在 DayCell 中添加周末判断：
```swift
let isWeekend = calendar.isDateInWeekend(date)
// 周末日期使用灰色或其他颜色
```

---

### 8. 完整设置面板 ⚠️ 高优先级

**需求（原型已实现，PRD 隐含）**：
Web 原型有完整设置面板，包括：
- 状态栏内容自定义
- 时间格式选择
- 日历显示选项（节假日、黄历开关）
- 交互方式配置（悬停/点击）

**当前状态**：
- ✅ 设置对话框框架
- ✅ 显示秒开关
- ❌ 其他所有设置项

**实现建议**：
```swift
struct SettingsView: View {
    // 状态栏显示
    @State var showDate = true
    @State var showLunar = true
    @State var showWeekday = true
    
    // 时间格式
    @State var timeFormat: TimeFormat = .twentyFourHour
    @State var showSeconds = true
    
    // 日历选项
    @State var showHolidays = true
    @State var showHuangli = false
    
    // 交互方式
    @State var triggerOnHover = false
}
```

---

### 9. 偏好设置持久化 ⚠️ 高优先级

**需求（隐含）**：
用户设置应该在重启后保留

**当前状态**：
- ❌ 所有设置都是临时的
- ❌ 未使用 UserDefaults

**实现建议**：
```swift
extension UserDefaults {
    var showSeconds: Bool {
        get { bool(forKey: "showSeconds") }
        set { set(newValue, forKey: "showSeconds") }
    }
    
    var timeFormat: TimeFormat {
        // ...
    }
}
```

---

### 10. 数据远程更新 🔵 低优先级

**需求（PRD 第 3 节）**：
> 数据同步：自动获取每年国务院公布的放假安排
> 需支持离线缓存

**当前状态**：
- ✅ API 集成（已实现）
- ✅ 离线缓存（SQLite）
- ❌ 自动检查更新
- ❌ 用户手动刷新功能

**实现建议**：
```swift
// 添加后台定时检查（每天检查一次）
// 添加设置中的"立即刷新"按钮
```

---

## 📊 优先级总结

### 🔴 高优先级（核心功能缺失）
1. **状态栏自定义显示** - 产品核心卖点
2. **24/12 小时制切换** - 基础时间功能
3. **完整设置面板** - 用户配置入口
4. **偏好设置持久化** - 基础体验

### 🟡 中优先级（体验增强）
5. **鼠标悬停触发** - 交互方式选项
6. **周末颜色区分** - 视觉增强

### 🔵 低优先级（附加功能）
7. **黄历功能** - 特色功能（可选）
8. **节气标注** - 传统文化元素
9. **传统节日标注** - 信息增强
10. **数据远程更新** - 维护便利性

---

## 🎯 建议开发顺序

### 第一阶段：核心功能补全
1. 实现状态栏自定义显示格式
2. 添加 24/12 小时制切换
3. 扩展设置面板（显示选项、时间格式）
4. 实现 UserDefaults 持久化

### 第二阶段：体验优化
5. 添加周末颜色区分
6. 实现鼠标悬停触发（可选）
7. 优化 UI 细节

### 第三阶段：特色功能
8. 移植黄历算法
9. 添加节气和传统节日数据
10. 完善数据更新机制

---

## 📝 参考资料

- **产品需求**: [documents/production.md](production.md)
- **技术规约**: [documents/tech.md](tech.md)
- **实现说明**: [documents/IMPLEMENTATION.md](IMPLEMENTATION.md)
- **Web 原型**: `prototype/` 目录
- **Figma 设计**: https://www.figma.com/design/Xelvq0vahTNFiGxxGv4nqh/日历应用

---

**更新日期**: 2026-02-16  
**当前版本**: 1.0.0  
**完成度**: 约 60% （核心功能已实现，定制化功能待开发）
