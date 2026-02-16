#!/bin/bash

# 快速打开 Xcode 项目的脚本
cd "$(dirname "$0")"

echo "🚀 正在打开 StatusbarCalendar Xcode 项目..."
open StatusbarCalendar.xcodeproj

echo "✅ 项目已在 Xcode 中打开"
echo ""
echo "接下来："
echo "  1. 等待 Xcode 加载完成"
echo "  2. 选择 StatusbarCalendar scheme"
echo "  3. 按 ⌘R 或点击运行按钮"
echo "  4. 在菜单栏查看时钟 🎉"
