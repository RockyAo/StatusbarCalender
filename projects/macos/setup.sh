#!/bin/bash

# StatusbarCalendar 快速启动脚本
# 用于使用 Xcode 创建和打开项目

echo "🚀 创建 StatusbarCalendar Xcode 项目..."

# 确保在正确的目录
cd "$(dirname "$0")"

# 使用 Swift Package Manager 生成 Xcode 项目
echo "📦 生成 Xcode 项目文件..."
swift package generate-xcodeproj 2>/dev/null || {
    echo "⚠️  注意: 使用 SPM 生成项目可能已被弃用"
    echo "💡 建议直接在 Xcode 中打开 Package.swift 文件"
    echo ""
    echo "执行以下命令:"
    echo "  open Package.swift"
    exit 1
}

# 打开生成的 Xcode 项目
if [ -f "StatusbarCalendar.xcodeproj/project.pbxproj" ]; then
    echo "✅ 项目创建成功！"
    echo "🎉 正在打开 Xcode..."
    open StatusbarCalendar.xcodeproj
else
    echo "❌ 项目创建失败"
    echo "💡 请直接在 Xcode 中打开 Package.swift"
    echo "   命令: open Package.swift"
fi
