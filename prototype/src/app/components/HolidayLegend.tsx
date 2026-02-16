import React from 'react';
import { Info } from 'lucide-react';

interface HolidayLegendProps {
  showHolidays: boolean;
  showWorkdays: boolean;
}

export function HolidayLegend({ showHolidays, showWorkdays }: HolidayLegendProps) {
  if (!showHolidays && !showWorkdays) return null;

  return (
    <div className="px-5 py-2 border-t border-gray-200/30 bg-gray-50/50">
      <div className="flex items-center gap-4 text-xs text-gray-600">
        <div className="flex items-center gap-1">
          <Info className="w-3 h-3" />
          <span>图例：</span>
        </div>
        {showHolidays && (
          <div className="flex items-center gap-1.5">
            <div className="flex items-center justify-center w-3.5 h-3.5 rounded-full bg-red-500 text-white text-[9px] font-bold">
              休
            </div>
            <span>法定假日</span>
          </div>
        )}
        {showWorkdays && (
          <div className="flex items-center gap-1.5">
            <div className="flex items-center justify-center w-3.5 h-3.5 rounded-full bg-orange-500 text-white text-[9px] font-bold">
              班
            </div>
            <span>调休补班</span>
          </div>
        )}
      </div>
    </div>
  );
}