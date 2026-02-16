import React from 'react';
import { HuangliInfo } from '../utils/huangli';

interface HuangliSectionProps {
  huangliInfo: HuangliInfo;
  show: boolean;
}

export function HuangliSection({ huangliInfo, show }: HuangliSectionProps) {
  if (!show) return null;

  return (
    <div className="px-5 py-4 border-t border-gray-200/50 bg-gradient-to-b from-amber-50/50 to-orange-50/30">
      {/* 标题行 */}
      <div className="flex items-center justify-between mb-3">
        <h3 className="text-sm font-medium text-gray-800">今日黄历</h3>
        <div className="flex items-center gap-2 text-xs text-gray-600">
          <span className="font-medium">{huangliInfo.ganZhi}日</span>
          <span className="text-gray-400">|</span>
          <span>生肖{huangliInfo.zodiac}</span>
        </div>
      </div>

      {/* 主要信息 */}
      <div className="grid grid-cols-2 gap-3 mb-3">
        <div className="bg-white/60 rounded-lg px-3 py-2">
          <div className="text-xs text-gray-500 mb-1">五行</div>
          <div className="text-sm text-gray-800 font-medium">{huangliInfo.wuXing}</div>
        </div>
        <div className="bg-white/60 rounded-lg px-3 py-2">
          <div className="text-xs text-gray-500 mb-1">建除</div>
          <div className="text-sm text-gray-800 font-medium">{huangliInfo.jianChu}</div>
        </div>
      </div>

      {/* 冲煞 */}
      <div className="bg-white/60 rounded-lg px-3 py-2 mb-3">
        <div className="flex items-center justify-between">
          <span className="text-xs text-gray-500">冲煞</span>
          <span className="text-sm text-gray-800 font-medium">{huangliInfo.chong}</span>
        </div>
      </div>

      {/* 宜忌 */}
      <div className="grid grid-cols-2 gap-3">
        {/* 宜 */}
        <div className="bg-green-50/60 rounded-lg px-3 py-2.5">
          <div className="flex items-center gap-1.5 mb-2">
            <span className="w-5 h-5 rounded-full bg-green-500 text-white text-xs flex items-center justify-center font-medium">
              宜
            </span>
            <span className="text-xs text-gray-600">适合做</span>
          </div>
          <div className="space-y-1">
            {huangliInfo.yi.map((item, index) => (
              <div key={index} className="text-xs text-gray-700">
                • {item}
              </div>
            ))}
          </div>
        </div>

        {/* 忌 */}
        <div className="bg-red-50/60 rounded-lg px-3 py-2.5">
          <div className="flex items-center gap-1.5 mb-2">
            <span className="w-5 h-5 rounded-full bg-red-500 text-white text-xs flex items-center justify-center font-medium">
              忌
            </span>
            <span className="text-xs text-gray-600">不宜做</span>
          </div>
          <div className="space-y-1">
            {huangliInfo.ji.map((item, index) => (
              <div key={index} className="text-xs text-gray-700">
                • {item}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 胎神占方 */}
      <div className="mt-3 bg-white/60 rounded-lg px-3 py-2">
        <div className="flex items-center justify-between">
          <span className="text-xs text-gray-500">胎神占方</span>
          <span className="text-xs text-gray-700">{huangliInfo.taiShen}</span>
        </div>
      </div>
    </div>
  );
}
