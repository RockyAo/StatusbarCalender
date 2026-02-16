#!/bin/bash

# StatusbarCalendar 调试脚本
# 用于清理构建缓存和重新构建应用

set -e

echo "🧹 清理 DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/StatusbarCalendar-*

echo "📦 项目目录: $(pwd)"
echo "📂 清理构建文件夹..."

if [ -d "build" ]; then
    rm -rf build
fi

echo "✅ 清理完成！"
echo ""
echo "📝 下一步操作："
echo "1. 在 Xcode 中打开项目: open StatusbarCalendar.xcodeproj"
echo "2. 按 ⌘⇧K 清理构建文件夹"
echo "3. 按 ⌘B 构建项目"
echo "4. 按 ⌘R 运行应用"
echo ""
echo "🔍 运行后请查看："
echo "   • Xcode 控制台是否有 '🚀 StatusbarCalendar App launching...' 消息"
echo "   • 菜单栏右上角是否出现时间显示"
echo "   • Dock 中应该没有应用图标"
echo ""
echo "💡 提示: 如果菜单栏仍然看不到图标，请尝试："
echo "   • 重启 macOS"
echo "   • 检查系统偏好设置 -> 隐私与安全性"
