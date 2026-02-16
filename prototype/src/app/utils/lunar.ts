import { Solar, Lunar } from 'lunar-javascript';

export interface LunarInfo {
  lunarDate: string; // 农历日期，如 "九月廿二"
  lunarMonth: string; // 农历月份，如 "九月"
  lunarDay: string; // 农历日，如 "廿二"
  yearInChinese: string; // 年份，如 "甲辰龙年"
  zodiac: string; // 生肖，如 "龙"
  solarTerm: string; // 节气，如果有的话
  festivals: string[]; // 节日
}

export function getLunarInfo(date: Date): LunarInfo {
  const solar = Solar.fromDate(date);
  const lunar = solar.getLunar();
  
  const lunarMonth = lunar.getMonthInChinese();
  const lunarDay = lunar.getDayInChinese();
  const lunarDate = `${lunarMonth}${lunarDay}`;
  
  const year = lunar.getYearInGanZhi();
  const zodiac = lunar.getYearShengXiao();
  const yearInChinese = `${year}${zodiac}年`;
  
  const solarTerm = lunar.getJieQi();
  
  const festivals: string[] = [];
  const lunarFestivals = lunar.getFestivals();
  const solarFestivals = solar.getFestivals();
  festivals.push(...lunarFestivals, ...solarFestivals);
  
  return {
    lunarDate,
    lunarMonth,
    lunarDay,
    yearInChinese,
    zodiac,
    solarTerm: solarTerm || '',
    festivals,
  };
}

// 获取指定月份的所有日期（包含上月和下月的填充日期）
export function getMonthDates(year: number, month: number): Date[] {
  const dates: Date[] = [];
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  
  // 获取第一天是星期几（0=周日，1=周一，...，6=周六）
  // 转换为周一为第一天（0=周一，1=周二，...，6=周日）
  let firstDayOfWeek = firstDay.getDay() - 1;
  if (firstDayOfWeek === -1) firstDayOfWeek = 6; // 周日
  
  // 添加上个月的日期来填充
  for (let i = firstDayOfWeek - 1; i >= 0; i--) {
    const date = new Date(year, month, -i);
    dates.push(date);
  }
  
  // 添加本月的所有日期
  for (let day = 1; day <= lastDay.getDate(); day++) {
    dates.push(new Date(year, month, day));
  }
  
  // 添加下个月的日期来填充完整的6周
  const remainingDays = 42 - dates.length; // 6周 x 7天 = 42天
  for (let day = 1; day <= remainingDays; day++) {
    dates.push(new Date(year, month + 1, day));
  }
  
  return dates;
}
