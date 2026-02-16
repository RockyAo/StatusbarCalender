import React from 'react';
import { X } from 'lucide-react';
import { motion } from 'motion/react';

export interface Settings {
  showDate: boolean;
  showWeekday: boolean;
  showLunar: boolean;
  showSeconds: boolean;
  use24Hour: boolean;
  showHolidays: boolean;
  showWorkdays: boolean;
  showHuangli: boolean;
  hoverToShow: boolean;
  autoStart: boolean;
}

interface SettingsDialogProps {
  isOpen: boolean;
  onClose: () => void;
  settings: Settings;
  onSettingsChange: (settings: Settings) => void;
}

export function SettingsDialog({
  isOpen,
  onClose,
  settings,
  onSettingsChange,
}: SettingsDialogProps) {
  if (!isOpen) return null;

  const handleCheckboxChange = (key: keyof Settings) => {
    onSettingsChange({
      ...settings,
      [key]: !settings[key],
    });
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center">
      {/* Backdrop */}
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        className="absolute inset-0 bg-black/30 backdrop-blur-sm"
        onClick={onClose}
      />

      {/* Dialog */}
      <motion.div
        initial={{ opacity: 0, scale: 0.95, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.95, y: 20 }}
        transition={{ duration: 0.2 }}
        className="relative w-[480px] bg-white/90 backdrop-blur-2xl rounded-2xl shadow-2xl border border-gray-200/50 overflow-hidden"
      >
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200/50">
          <h2 className="text-lg">设置</h2>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-lg hover:bg-gray-200/50 flex items-center justify-center transition-colors"
          >
            <X className="w-5 h-5 text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="px-6 py-5 space-y-6">
          {/* 状态栏内容 */}
          <div>
            <h3 className="text-sm text-gray-700 mb-3">状态栏内容</h3>
            <div className="space-y-2.5">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showDate}
                  onChange={() => handleCheckboxChange('showDate')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示日期
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showWeekday}
                  onChange={() => handleCheckboxChange('showWeekday')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示星期
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showLunar}
                  onChange={() => handleCheckboxChange('showLunar')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示农历
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showSeconds}
                  onChange={() => handleCheckboxChange('showSeconds')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示秒
                </span>
              </label>
            </div>
          </div>

          {/* 时间格式 */}
          <div>
            <h3 className="text-sm text-gray-700 mb-3">时间格式</h3>
            <div className="space-y-2.5">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="radio"
                  checked={settings.use24Hour}
                  onChange={() => onSettingsChange({ ...settings, use24Hour: true })}
                  className="w-4 h-4 border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  24小时制
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="radio"
                  checked={!settings.use24Hour}
                  onChange={() => onSettingsChange({ ...settings, use24Hour: false })}
                  className="w-4 h-4 border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  12小时制 (显示 AM/PM)
                </span>
              </label>
            </div>
          </div>

          {/* 节假日 */}
          <div>
            <h3 className="text-sm text-gray-700 mb-3">节假日</h3>
            <div className="space-y-2.5">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showHolidays}
                  onChange={() => handleCheckboxChange('showHolidays')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示中国法定节假日
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showWorkdays}
                  onChange={() => handleCheckboxChange('showWorkdays')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  标记调休补班
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.showHuangli}
                  onChange={() => handleCheckboxChange('showHuangli')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  显示黄历
                </span>
              </label>
            </div>
          </div>

          {/* 视觉样式 */}
          <div>
            <h3 className="text-sm text-gray-700 mb-3">视觉样式</h3>
            <div className="space-y-2.5">
              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.hoverToShow}
                  onChange={() => handleCheckboxChange('hoverToShow')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  悬停即显示面板 (否则需点击)
                </span>
              </label>

              <label className="flex items-center gap-3 cursor-pointer group">
                <input
                  type="checkbox"
                  checked={settings.autoStart}
                  onChange={() => handleCheckboxChange('autoStart')}
                  className="w-4 h-4 rounded border-gray-300 text-blue-500 focus:ring-blue-500 focus:ring-offset-0"
                />
                <span className="text-sm text-gray-700 group-hover:text-gray-900">
                  启动开机自启
                </span>
              </label>
            </div>
          </div>
        </div>

        {/* Footer */}
        <div className="px-6 py-4 border-t border-gray-200/50 flex justify-end">
          <button
            onClick={onClose}
            className="px-4 py-2 bg-blue-500 text-white text-sm rounded-lg hover:bg-blue-600 transition-colors"
          >
            完成
          </button>
        </div>
      </motion.div>
    </div>
  );
}