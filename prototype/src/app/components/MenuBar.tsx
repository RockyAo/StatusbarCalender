import React from 'react';
import { getLunarInfo } from '../utils/lunar';
import type { Settings } from './SettingsDialog';

interface MenuBarProps {
  onInteract: () => void;
  isHovered: boolean;
  settings: Settings;
}

export function MenuBar({ onInteract, isHovered, settings }: MenuBarProps) {
  const [currentTime, setCurrentTime] = React.useState(new Date());

  React.useEffect(() => {
    const timer = setInterval(() => {
      setCurrentTime(new Date());
    }, 1000);

    return () => clearInterval(timer);
  }, []);

  const lunarInfo = settings.showLunar ? getLunarInfo(currentTime) : null;

  const formatTime = () => {
    const hours = currentTime.getHours();
    const minutes = currentTime.getMinutes();
    const seconds = currentTime.getSeconds();

    if (settings.use24Hour) {
      const timeStr = `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
      return settings.showSeconds ? `${timeStr}:${String(seconds).padStart(2, '0')}` : timeStr;
    } else {
      const period = hours >= 12 ? 'PM' : 'AM';
      const displayHours = hours % 12 || 12;
      const timeStr = `${displayHours}:${String(minutes).padStart(2, '0')}`;
      const withSeconds = settings.showSeconds ? `${timeStr}:${String(seconds).padStart(2, '0')}` : timeStr;
      return `${withSeconds} ${period}`;
    }
  };

  const formatDate = () => {
    const month = currentTime.getMonth() + 1;
    const day = currentTime.getDate();
    return `${month}月${day}日`;
  };

  const getWeekday = () => {
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
    return weekdays[currentTime.getDay()];
  };

  return (
    <div
      className={`
        inline-flex items-center gap-2 px-3 py-1.5 rounded-lg
        transition-all duration-200 cursor-pointer select-none
        ${isHovered ? 'bg-gray-200/60' : 'bg-transparent'}
      `}
      onMouseEnter={settings.hoverToShow ? onInteract : undefined}
      onClick={!settings.hoverToShow ? onInteract : undefined}
    >
      {settings.showDate && (
        <span className="text-sm text-gray-900">{formatDate()}</span>
      )}
      {settings.showWeekday && (
        <span className="text-sm text-gray-900">{getWeekday()}</span>
      )}
      {settings.showLunar && lunarInfo && (
        <span className="text-sm text-gray-600">{lunarInfo.lunarDate}</span>
      )}
      <span className="text-sm text-gray-900">{formatTime()}</span>
    </div>
  );
}
