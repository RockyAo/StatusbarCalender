# StatusbarCalendar - 日历视图实现说明

## ✅ 已完成功能

### 1. 核心组件

#### 📅 日历网格视图 (CalendarGridView)
- 使用 `LazyVGrid` 实现 7 列布局（周日到周六）
- 自动计算并显示每月所有日期（包括前后月份的溢出日期）
- 月份切换功能（上一月/下一月），自动加载对应年份数据
- "回到今天" 快捷按钮
- 毛玻璃背景效果（`.ultraThinMaterial`）

#### 🗓 日期单元格 (DayCell)
- **日期数字**: 显示当天的阳历日期
- **农历文字**: 显示对应的农历（初一显示月份，其他显示日期）
- **今日高亮**: 蓝色背景和白色文字标记今天
- **节假日角标**: 
  - "休" - 红色圆形角标（法定节假日）左上角 14px
  - "班" - 橙色圆形角标（调休补班）左上角 14px
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
- 月份导航逻辑，切换月份时自动加载对应年份的节假日数据
- 日期信息自动计算

#### 🎉 节假日服务 (HolidayService)
- **数据源 API**: `https://date.appworlds.cn/year/{year}`
- **智能加载**: 按年份请求数据，内存缓存已加载年份
- **数据格式**: `{code: 200, data: [{date, days, holiday, name}]}`
- **自动同步**: App 启动时加载当前年份，切换月份时按需加载
- **状态管理**: `@Observable` 支持 UI 自动刷新

#### 💾 数据库管理 (HolidayDatabase)
- **存储引擎**: SQLite3 原生 C API
- **表结构**: 
  - `holidays`: date (PK), is_holiday, name, days, updated_at
  - `metadata`: key (PK), value (存储同步状态)
- **数据迁移**: 自动检测旧表结构并重建
- **存储位置**: `~/Library/Application Support/com.example.StatusbarCalendar/holidays.db`
- **事务支持**: 批量插入使用事务确保数据一致性

### 2. 数据模型

```swift
DayInfo: 日期信息模型
├── date: Date               // 具体日期
├── day: Int                 // 日期数字
├── isCurrentMonth: Bool     // 是否当前月
├── isToday: Bool           // 是否今天
├── lunarText: String       // 农历文字
├── status: DayStatus       // 节假日状态
├── holidayName: String?    // 节日名称
├── isSolarTerm: Bool       // 是否节气
└── isFestival: Bool        // 是否传统节日

DayStatus: 节假日状态枚举
├── holiday  // 法定假期（显示红色"休"）
├── workday  // 调休补班（显示橙色"班"）
└── normal   // 普通日

HolidayResponse: API 响应结构
├── code: Int               // 状态码 (200 成功)
└── data: [HolidayDay]     // 节假日数组

HolidayDay: 单个节假日
├── date: String           // YYYY-MM-DD
├── days: Int              // 假期总天数 (补班为 0)
├── holiday: Bool          // true=假期, false=补班
└── name: String           // 节日名称

StoredHoliday: 本地存储
├── date: String           // YYYY-MM-DD
├── isHoliday: Bool       // true=假期, false=补班
├── name: String          // 节日名称
└── days: Int             // 假期总天数
```

### 3. 视觉设计特性

✅ 符合 Figma 设计规范:
- 面板宽度: 380px
- 圆角: 16px (面板) / 8px (单元格)
- 毛玻璃效果: `.ultraThinMaterial`
- 字体:
  - 月份标题: 16pt, Semibold
  - 日期数字: 16pt (今日 Semibold)
  - 农历文字: 10pt, Secondary 色
  - 角标文字: 9pt, White
- 间距: 4pt (单元格) / 16pt (面板)
- 今日样式:
  - 背景: `bg-blue-500`
  - 文字: 白色
  - 圆角: 8px
- 节假日角标:
  - 位置: 左上角
  - 尺寸: 14px 圆形
  - "休": 红色背景 (#EF4444)
  - "班": 橙色背景 (#F97316)
  - 文字: 白色 9pt Medium

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

4. 点击菜单栏日历图标查看日历面板

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
├── SettingsView.swift           # 设置界面
├── HolidayService.swift         # 节假日服务
├── HolidayModels.swift          # 节假日数据模型
├── HolidayDatabase.swift        # SQLite 数据库
└── Info.plist                   # 应用配置
```

## 📸 功能演示

### 日历面板包含:
1. **顶部信息栏**: 当前日期、农历信息、实时时间
2. **月份导航**: 上一月 / 下一月切换（自动加载年份数据）
3. **星期标题**: 日一二三四五六
4. **日期网格**: 7x6 布局，展示完整月视图
5. **底部操作**: 设置和退出按钮

### 日期单元格展示:
- **阳历日期** (16pt 大字)
- **农历信息** (10pt 小字，灰色)
- **今日标记** (蓝色背景，白色文字)
- **节假日角标** (左上角 14px 圆形 "休" 或 "班")

### 节假日数据流程:
1. **App 启动**: 加载当前年份数据（2026）
2. **切换月份**: 自动检测并加载新年份数据
3. **数据缓存**: 已加载年份存储在内存，避免重复请求
4. **数据库持久化**: SQLite 存储，下次启动直接读取
5. **UI 刷新**: 数据更新后自动触发视图重绘

## 🔜 后续优化

### 性能优化
- [ ] 日期计算结果缓存
- [ ] 视图复用优化
- [ ] 数据库查询索引优化

### 功能增强
- [ ] 节气和传统节日标记
- [ ] 自定义节假日
- [ ] 多年份数据预加载
- [ ] 网络请求失败重试机制

## 🐛 已知问题

无 - 当前版本稳定运行

## 📝 技术亮点

1. **纯 Swift 原生**: 无第三方依赖
2. **农历支持**: Apple 原生 Calendar API
3. **类型安全**: Swift 6 严格并发检查通过
4. **声明式 UI**: 100% SwiftUI 实现
5. **高性能**: LazyVGrid 按需渲染
6. **智能数据加载**: 按年份动态请求，内存缓存
7. **数据持久化**: SQLite 本地存储
8. **自动迁移**: 检测旧数据结构并自动升级

## 🎨 设计规范

设计稿地址: https://cactus-axis-25725963.figma.site

当前实现已严格遵循:
- ✅ 面板宽度 380px
- ✅ 圆角 16px (面板) / 8px (单元格)
- ✅ 今日蓝色背景效果
- ✅ 左上角 14px 圆形角标
- ✅ 字体层级和大小
- ✅ 间距系统
- ✅ 毛玻璃效果

## 🌐 API 集成

### 节假日数据 API

**端点**: `https://date.appworlds.cn/year/{year}`

**请求示例**:
```
GET https://date.appworlds.cn/year/2026
```

**响应格式**:
```json
{
  "code": 200,
  "data": [
    {
      "date": "2026-01-01",
      "days": 3,
      "holiday": true,
      "name": "元旦"
    },
    {
      "date": "2026-01-04",
      "days": 0,
      "holiday": false,
      "name": "元旦后补班"
    }
  ]
}
```

**字段说明**:
- `code`: 状态码，200 表示成功
- `data`: 节假日数组
  - `date`: 日期 (YYYY-MM-DD)
  - `days`: 假期总天数（补班为 0）
  - `holiday`: true=假期, false=补班
  - `name`: 节日名称

### 数据加载策略

1. **启动时**: 加载当前年份（2026）
2. **切换月份**: 检测年份变化，按需加载
3. **内存缓存**: `loadedYears` Set 跟踪已加载年份
4. **数据库缓存**: SQLite 持久化，避免重复请求
5. **自动刷新**: 数据更新后触发 `lastUpdateTime` 变化

## 🔧 数据库设计

### 表结构

**holidays 表**:
```sql
CREATE TABLE holidays (
    date TEXT PRIMARY KEY,          -- YYYY-MM-DD
    is_holiday INTEGER NOT NULL,    -- 1=假期, 0=补班
    name TEXT NOT NULL,             -- 节日名称
    days INTEGER NOT NULL,          -- 假期天数
    updated_at TEXT NOT NULL        -- 更新时间戳
);
```

**metadata 表**:
```sql
CREATE TABLE metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
```

存储同步状态：
- `last_sync_year`: 最后同步的年份
- `last_sync_date`: 最后同步时间

### 数据迁移

自动检测旧表结构（包含 `wage` 字段），执行 `DROP TABLE` 重建。

## 🐛 调试技巧

### 查看数据库内容
```bash
sqlite3 ~/Library/Application\ Support/com.example.StatusbarCalendar/holidays.db
.tables
SELECT * FROM holidays LIMIT 10;
SELECT * FROM metadata;
```

### 清空缓存重新同步
```bash
rm -rf ~/Library/Application\ Support/com.example.StatusbarCalendar/
```

### 控制台日志标识
- 📂 数据库操作
- 🔄 网络请求
- ✅ 成功操作
- ❌ 错误信息
- 📅 初始化信息

---

**更新日期**: 2026-02-16  
**版本**: 1.0.0  
**状态**: ✅ Step 3 节假日集成已完成
