# StatusbarCalendar - 项目结构

## 目录说明

```
StatusbarCalendar/
├── Models/              # 数据模型和枚举
│   ├── DayStatus.swift         # 日期状态枚举
│   ├── DisplayOptions.swift    # 显示选项模型和枚举
│   └── HolidayModels.swift     # 节假日数据模型
│
├── Views/               # SwiftUI 视图组件
│   ├── CalendarGridView.swift  # 日历网格视图
│   ├── DayCell.swift           # 日期单元格视图
│   ├── MenuBarView.swift       # 菜单栏面板视图
│   └── SettingsView.swift      # 设置页面视图
│
├── Services/            # 业务逻辑和服务
│   ├── CalendarManager.swift   # 日历管理服务
│   ├── ClockManager.swift      # 时钟管理服务
│   ├── HolidayDatabase.swift   # 节假日数据库
│   ├── HolidayService.swift    # 节假日服务
│   ├── LunarCalendar.swift     # 农历服务
│   ├── MenuBarManager.swift    # 菜单栏管理服务（悬停检测）
│   └── SettingsWindow.swift    # 设置窗口管理
│
├── Resources/           # 资源文件
│   └── Assets.xcassets         # 应用图标和资源
│
├── Scripts/             # 脚本文件（预留）
│
├── AppDelegate.swift           # 应用委托
├── StatusbarCalendarApp.swift  # 应用入口
└── Info.plist                  # 应用配置
```

## 开发说明

- **Models**: 存放所有数据模型、枚举类型和数据结构定义
- **Views**: 存放所有 SwiftUI 视图组件
- **Services**: 存放业务逻辑、数据服务、管理器等
- **Resources**: 存放图片、图标等静态资源
- **Scripts**: 存放构建脚本、工具脚本等
