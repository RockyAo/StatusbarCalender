import React from 'react';
import { MenuBar } from './components/MenuBar';
import { CalendarPopover } from './components/CalendarPopover';
import { SettingsDialog, Settings } from './components/SettingsDialog';
import { AnimatePresence } from 'motion/react';

export default function App() {
  const [showPopover, setShowPopover] = React.useState(false);
  const [showSettings, setShowSettings] = React.useState(false);
  const [isHovered, setIsHovered] = React.useState(false);
  const [settings, setSettings] = React.useState<Settings>({
    showDate: true,
    showWeekday: true,
    showLunar: true,
    showSeconds: true,
    use24Hour: true,
    showHolidays: true,
    showWorkdays: true,
    showHuangli: false,
    hoverToShow: false,
    autoStart: false,
  });

  const popoverRef = React.useRef<HTMLDivElement>(null);
  const menuBarRef = React.useRef<HTMLDivElement>(null);

  React.useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        popoverRef.current &&
        menuBarRef.current &&
        !popoverRef.current.contains(event.target as Node) &&
        !menuBarRef.current.contains(event.target as Node)
      ) {
        setShowPopover(false);
        setIsHovered(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleMenuBarInteract = () => {
    setShowPopover(true);
  };

  const handleMenuBarLeave = () => {
    if (settings.hoverToShow) {
      // 给一个小延迟，允许用户移动到popover
      setTimeout(() => {
        if (!isHovered) {
          setShowPopover(false);
        }
      }, 200);
    }
  };

  return (
    <div className="size-full flex flex-col bg-gradient-to-br from-blue-50 to-purple-50">
      {/* 模拟 macOS 状态栏 */}
      <div className="w-full bg-white/80 backdrop-blur-xl border-b border-gray-200/50 shadow-sm">
        <div className="max-w-screen-2xl mx-auto px-6 h-14 flex items-center justify-end">
          <div
            ref={menuBarRef}
            onMouseEnter={() => setIsHovered(true)}
            onMouseLeave={handleMenuBarLeave}
          >
            <MenuBar
              onInteract={handleMenuBarInteract}
              isHovered={isHovered}
              settings={settings}
            />
          </div>
        </div>
      </div>

      {/* 日历弹出层 */}
      <div className="relative">
        <AnimatePresence>
          {showPopover && (
            <div
              ref={popoverRef}
              className="absolute top-4 right-6 z-50"
              onMouseEnter={() => setIsHovered(true)}
              onMouseLeave={() => {
                setIsHovered(false);
                if (settings.hoverToShow) {
                  setShowPopover(false);
                }
              }}
            >
              <CalendarPopover
                onOpenSettings={() => {
                  setShowSettings(true);
                  setShowPopover(false);
                }}
                settings={settings}
              />
            </div>
          )}
        </AnimatePresence>
      </div>

      {/* 设置对话框 */}
      <AnimatePresence>
        {showSettings && (
          <SettingsDialog
            isOpen={showSettings}
            onClose={() => setShowSettings(false)}
            settings={settings}
            onSettingsChange={setSettings}
          />
        )}
      </AnimatePresence>

      {/* 主内容区域 - 展示应用介绍 */}
      <div className="flex-1 flex items-center justify-center p-8">
        <div className="max-w-2xl text-center space-y-6">
          <div className="space-y-2">
            <h1 className="text-4xl text-gray-900">
              macOS 日历状态栏
            </h1>
            <p className="text-lg text-gray-600">
              简洁优雅的系统级日历应用
            </p>
          </div>

          <div className="bg-white/60 backdrop-blur-xl rounded-2xl p-8 border border-gray-200/50 space-y-4 text-left">
            <div>
              <h3 className="text-sm text-gray-700 mb-2">✨ 核心功能</h3>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• 状态栏实时显示日期、时间、星期、农历</li>
                <li>• 完整的日历视图，支持农历、节气、节日</li>
                <li>• 中国法定节假日标记（休息日 / 调休补班）</li>
                <li>• 高度自定义的显示选项</li>
              </ul>
            </div>

            <div>
              <h3 className="text-sm text-gray-700 mb-2">🎨 设计特色</h3>
              <ul className="text-sm text-gray-600 space-y-1">
                <li>• 毛玻璃质感，完美融入 macOS</li>
                <li>• 流畅的动画效果</li>
                <li>• 支持悬停或点击触发</li>
                <li>• 系统强调色突出今日</li>
              </ul>
            </div>

            <div className="pt-4 border-t border-gray-200/50">
              <p className="text-xs text-gray-500 text-center">
                点击右上角状态栏开始使用 →
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}