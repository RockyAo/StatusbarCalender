import React from 'react';
import { ChevronLeft, ChevronRight, CalendarDays, Settings } from 'lucide-react';
import { getLunarInfo, getMonthDates } from '../utils/lunar';
import { getHolidayInfo } from '../utils/holidays';
import { getHuangliInfo } from '../utils/huangli';
import { motion, AnimatePresence } from 'motion/react';
import { HolidayLegend } from './HolidayLegend';
import { HuangliSection } from './HuangliSection';

interface CalendarPopoverProps {
  onOpenSettings: () => void;
  settings: {
    showLunar: boolean;
    showHolidays: boolean;
    showWorkdays: boolean;
    showHuangli: boolean;
  };
}

export function CalendarPopover({ onOpenSettings, settings }: CalendarPopoverProps) {
  const [currentDate, setCurrentDate] = React.useState(new Date());
  const [selectedMonth, setSelectedMonth] = React.useState(new Date().getMonth());
  const [selectedYear, setSelectedYear] = React.useState(new Date().getFullYear());

  const dates = getMonthDates(selectedYear, selectedMonth);
  const todayStr = new Date().toDateString();
  const todayLunarInfo = getLunarInfo(new Date());
  const todayHuangliInfo = getHuangliInfo(new Date());

  const weekDays = ['一', '二', '三', '四', '五', '六', '日'];

  const goToPrevMonth = () => {
    if (selectedMonth === 0) {
      setSelectedMonth(11);
      setSelectedYear(selectedYear - 1);
    } else {
      setSelectedMonth(selectedMonth - 1);
    }
  };

  const goToNextMonth = () => {
    if (selectedMonth === 11) {
      setSelectedMonth(0);
      setSelectedYear(selectedYear + 1);
    } else {
      setSelectedMonth(selectedMonth + 1);
    }
  };

  const goToToday = () => {
    const today = new Date();
    setSelectedYear(today.getFullYear());
    setSelectedMonth(today.getMonth());
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: -10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.2 }}
      className="w-[380px] bg-white/80 backdrop-blur-2xl rounded-2xl shadow-2xl border border-gray-200/50 overflow-hidden"
    >
      {/* Header */}
      <div className="px-5 py-4 border-b border-gray-200/50">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <h2 className="text-xl select-none">
              {selectedYear}年 {selectedMonth + 1}月
            </h2>
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={goToPrevMonth}
              className="w-7 h-7 rounded-lg hover:bg-gray-200/50 flex items-center justify-center transition-colors"
            >
              <ChevronLeft className="w-4 h-4 text-gray-600" />
            </button>
            <button
              onClick={goToToday}
              className="w-7 h-7 rounded-lg hover:bg-gray-200/50 flex items-center justify-center transition-colors"
              title="回到今天"
            >
              <CalendarDays className="w-4 h-4 text-gray-600" />
            </button>
            <button
              onClick={goToNextMonth}
              className="w-7 h-7 rounded-lg hover:bg-gray-200/50 flex items-center justify-center transition-colors"
            >
              <ChevronRight className="w-4 h-4 text-gray-600" />
            </button>
          </div>
        </div>
      </div>

      {/* Week Days Header */}
      <div className="grid grid-cols-7 gap-1 px-4 py-2 border-b border-gray-200/30">
        {weekDays.map((day, index) => (
          <div
            key={day}
            className={`text-center text-xs ${
              index >= 5 ? 'text-gray-400' : 'text-gray-600'
            }`}
          >
            {day}
          </div>
        ))}
      </div>

      {/* Calendar Grid */}
      <div className="grid grid-cols-7 gap-1 px-4 py-3">
        {dates.map((date, index) => {
          const isToday = date.toDateString() === todayStr;
          const isCurrentMonth = date.getMonth() === selectedMonth;
          const lunarInfo = settings.showLunar ? getLunarInfo(date) : null;
          const holidayInfo = settings.showHolidays ? getHolidayInfo(date) : null;
          const isWeekend = date.getDay() === 0 || date.getDay() === 6;

          // 显示优先级：节气 > 节日 > 农历
          let subText = '';
          if (settings.showLunar) {
            if (lunarInfo?.solarTerm) {
              subText = lunarInfo.solarTerm;
            } else if (lunarInfo?.festivals.length) {
              subText = lunarInfo.festivals[0];
            } else if (lunarInfo?.lunarDay === '初一') {
              subText = lunarInfo.lunarMonth;
            } else {
              subText = lunarInfo?.lunarDay || '';
            }
          }

          // 确定背景色
          let bgColor = '';
          if (isToday) {
            bgColor = 'bg-blue-500 text-white';
          } else if (holidayInfo?.isOffDay && settings.showHolidays) {
            bgColor = 'bg-red-50 hover:bg-red-100';
          } else if (holidayInfo && !holidayInfo.isOffDay && settings.showWorkdays) {
            bgColor = 'bg-orange-50 hover:bg-orange-100';
          } else {
            bgColor = 'hover:bg-gray-100/50';
          }

          return (
            <div
              key={index}
              className={`
                relative aspect-square flex flex-col items-center justify-center rounded-lg
                transition-all cursor-pointer select-none p-1
                ${isCurrentMonth ? 'text-gray-900' : 'text-gray-400'}
                ${bgColor}
              `}
              title={holidayInfo ? holidayInfo.name : ''}
            >
              {/* 节假日标记 - 左上角小圆点样式 */}
              {holidayInfo && settings.showHolidays && (
                <div className="absolute top-1 left-1">
                  {holidayInfo.isOffDay ? (
                    <div className="flex items-center justify-center w-3.5 h-3.5 rounded-full bg-red-500 text-white text-[9px] font-bold leading-none">
                      休
                    </div>
                  ) : settings.showWorkdays ? (
                    <div className="flex items-center justify-center w-3.5 h-3.5 rounded-full bg-orange-500 text-white text-[9px] font-bold leading-none">
                      班
                    </div>
                  ) : null}
                </div>
              )}

              {/* 日期 */}
              <div className={`text-sm ${isToday ? 'font-semibold' : holidayInfo?.isOffDay ? 'font-medium' : ''}`}>
                {date.getDate()}
              </div>

              {/* 农历/节气/节日 */}
              {settings.showLunar && subText && (
                <div
                  className={`text-[10px] leading-none mt-0.5 ${
                    isToday
                      ? 'text-blue-100'
                      : lunarInfo?.solarTerm || lunarInfo?.festivals.length
                      ? 'text-red-600 font-medium'
                      : 'text-gray-500'
                  }`}
                >
                  {subText}
                </div>
              )}
            </div>
          );
        })}
      </div>

      {/* Footer */}
      <div className="px-5 py-3 border-t border-gray-200/50 flex items-center justify-between">
        <div className="text-xs text-gray-600">
          {todayLunarInfo.yearInChinese} {todayLunarInfo.lunarDate}
        </div>
        <button
          onClick={onOpenSettings}
          className="w-7 h-7 rounded-lg hover:bg-gray-200/50 flex items-center justify-center transition-colors"
          title="设置"
        >
          <Settings className="w-4 h-4 text-gray-600" />
        </button>
      </div>

      {/* Holiday Legend */}
      <HolidayLegend showHolidays={settings.showHolidays} showWorkdays={settings.showWorkdays} />
      
      {/* Huangli Section */}
      <HuangliSection huangliInfo={todayHuangliInfo} show={settings.showHuangli} />
    </motion.div>
  );
}