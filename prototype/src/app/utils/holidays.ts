// 中国节假日数据 (2024-2026)
export interface Holiday {
  date: string; // YYYY-MM-DD
  name: string;
  isOffDay: boolean; // true=休息日，false=补班日
}

export const holidays2024: Holiday[] = [
  // 元旦 (2023-12-30至2024-1-1)
  { date: '2024-01-01', name: '元旦', isOffDay: true },
  
  // 春节 (2-10至2-17)
  { date: '2024-02-04', name: '春节调休', isOffDay: false },
  { date: '2024-02-10', name: '除夕', isOffDay: true },
  { date: '2024-02-11', name: '春节', isOffDay: true },
  { date: '2024-02-12', name: '春节', isOffDay: true },
  { date: '2024-02-13', name: '春节', isOffDay: true },
  { date: '2024-02-14', name: '春节', isOffDay: true },
  { date: '2024-02-15', name: '春节', isOffDay: true },
  { date: '2024-02-16', name: '春节', isOffDay: true },
  { date: '2024-02-17', name: '春节', isOffDay: true },
  { date: '2024-02-18', name: '春节调休', isOffDay: false },
  
  // 清明节 (4-4至4-6)
  { date: '2024-04-04', name: '清明节', isOffDay: true },
  { date: '2024-04-05', name: '清明节', isOffDay: true },
  { date: '2024-04-06', name: '清明节', isOffDay: true },
  { date: '2024-04-07', name: '清明调休', isOffDay: false },
  
  // 劳动节 (5-1至5-5)
  { date: '2024-04-28', name: '劳动节调休', isOffDay: false },
  { date: '2024-05-01', name: '劳动节', isOffDay: true },
  { date: '2024-05-02', name: '劳动节', isOffDay: true },
  { date: '2024-05-03', name: '劳动节', isOffDay: true },
  { date: '2024-05-04', name: '劳动节', isOffDay: true },
  { date: '2024-05-05', name: '劳动节', isOffDay: true },
  { date: '2024-05-11', name: '劳动节调休', isOffDay: false },
  
  // 端午节 (6-8至6-10)
  { date: '2024-06-08', name: '端午节', isOffDay: true },
  { date: '2024-06-09', name: '端午节', isOffDay: true },
  { date: '2024-06-10', name: '端午节', isOffDay: true },
  
  // 中秋节 (9-15至9-17)
  { date: '2024-09-14', name: '中秋节调休', isOffDay: false },
  { date: '2024-09-15', name: '中秋节', isOffDay: true },
  { date: '2024-09-16', name: '中秋节', isOffDay: true },
  { date: '2024-09-17', name: '中秋节', isOffDay: true },
  
  // 国庆节 (10-1至10-7)
  { date: '2024-09-29', name: '国庆节调休', isOffDay: false },
  { date: '2024-10-01', name: '国庆节', isOffDay: true },
  { date: '2024-10-02', name: '国庆节', isOffDay: true },
  { date: '2024-10-03', name: '国庆节', isOffDay: true },
  { date: '2024-10-04', name: '国庆节', isOffDay: true },
  { date: '2024-10-05', name: '国庆节', isOffDay: true },
  { date: '2024-10-06', name: '国庆节', isOffDay: true },
  { date: '2024-10-07', name: '国庆节', isOffDay: true },
  { date: '2024-10-12', name: '国庆节调休', isOffDay: false },
];

export const holidays2025: Holiday[] = [
  // 元旦
  { date: '2025-01-01', name: '元旦', isOffDay: true },
  
  // 春节
  { date: '2025-01-26', name: '春节调休', isOffDay: false },
  { date: '2025-01-28', name: '除夕', isOffDay: true },
  { date: '2025-01-29', name: '春节', isOffDay: true },
  { date: '2025-01-30', name: '春节', isOffDay: true },
  { date: '2025-01-31', name: '春节', isOffDay: true },
  { date: '2025-02-01', name: '春节', isOffDay: true },
  { date: '2025-02-02', name: '春节', isOffDay: true },
  { date: '2025-02-03', name: '春节', isOffDay: true },
  { date: '2025-02-04', name: '春节', isOffDay: true },
  { date: '2025-02-08', name: '春节调休', isOffDay: false },
  
  // 清明节
  { date: '2025-04-04', name: '清明节', isOffDay: true },
  { date: '2025-04-05', name: '清明节', isOffDay: true },
  { date: '2025-04-06', name: '清明节', isOffDay: true },
  
  // 劳动节
  { date: '2025-04-27', name: '劳动节调休', isOffDay: false },
  { date: '2025-05-01', name: '劳动节', isOffDay: true },
  { date: '2025-05-02', name: '劳动节', isOffDay: true },
  { date: '2025-05-03', name: '劳动节', isOffDay: true },
  { date: '2025-05-04', name: '劳动节', isOffDay: true },
  { date: '2025-05-05', name: '劳动节', isOffDay: true },
  
  // 端午节
  { date: '2025-05-31', name: '端午节', isOffDay: true },
  { date: '2025-06-01', name: '端午节', isOffDay: true },
  { date: '2025-06-02', name: '端午节', isOffDay: true },
  
  // 中秋节
  { date: '2025-10-06', name: '中秋节', isOffDay: true },
  
  // 国庆节
  { date: '2025-09-28', name: '国庆节调休', isOffDay: false },
  { date: '2025-10-01', name: '国庆节', isOffDay: true },
  { date: '2025-10-02', name: '国庆节', isOffDay: true },
  { date: '2025-10-03', name: '国庆节', isOffDay: true },
  { date: '2025-10-04', name: '国庆节', isOffDay: true },
  { date: '2025-10-05', name: '国庆节', isOffDay: true },
  { date: '2025-10-07', name: '国庆节', isOffDay: true },
  { date: '2025-10-08', name: '国庆节', isOffDay: true },
  { date: '2025-10-11', name: '国庆节调休', isOffDay: false },
];

export const holidays2026: Holiday[] = [
  // 元旦
  { date: '2026-01-01', name: '元旦', isOffDay: true },
  { date: '2026-01-02', name: '元旦', isOffDay: true },
  { date: '2026-01-03', name: '元旦', isOffDay: true },
  
  // 春节 (2月17日-23日)
  { date: '2026-02-15', name: '春节调休', isOffDay: false },
  { date: '2026-02-16', name: '除夕', isOffDay: true },
  { date: '2026-02-17', name: '春节', isOffDay: true },
  { date: '2026-02-18', name: '春节', isOffDay: true },
  { date: '2026-02-19', name: '春节', isOffDay: true },
  { date: '2026-02-20', name: '春节', isOffDay: true },
  { date: '2026-02-21', name: '春节', isOffDay: true },
  { date: '2026-02-22', name: '春节', isOffDay: true },
  { date: '2026-02-23', name: '春节', isOffDay: true },
  { date: '2026-02-28', name: '春节调休', isOffDay: false },
  
  // 清明节 (4月5日-7日)
  { date: '2026-04-05', name: '清明节', isOffDay: true },
  { date: '2026-04-06', name: '清明节', isOffDay: true },
  { date: '2026-04-07', name: '清明节', isOffDay: true },
  
  // 劳动节 (5月1日-5日)
  { date: '2026-04-26', name: '劳动节调休', isOffDay: false },
  { date: '2026-05-01', name: '劳动节', isOffDay: true },
  { date: '2026-05-02', name: '劳动节', isOffDay: true },
  { date: '2026-05-03', name: '劳动节', isOffDay: true },
  { date: '2026-05-04', name: '劳动节', isOffDay: true },
  { date: '2026-05-05', name: '劳动节', isOffDay: true },
  { date: '2026-05-09', name: '劳动节调休', isOffDay: false },
  
  // 端午节 (6月19日-21日)
  { date: '2026-06-19', name: '端午节', isOffDay: true },
  { date: '2026-06-20', name: '端午节', isOffDay: true },
  { date: '2026-06-21', name: '端午节', isOffDay: true },
  
  // 中秋节 (9月25日-27日)
  { date: '2026-09-25', name: '中秋节', isOffDay: true },
  { date: '2026-09-26', name: '中秋节', isOffDay: true },
  { date: '2026-09-27', name: '中秋节', isOffDay: true },
  
  // 国庆节 (10月1日-8日)
  { date: '2026-09-27', name: '国庆节调休', isOffDay: false },
  { date: '2026-10-01', name: '国庆节', isOffDay: true },
  { date: '2026-10-02', name: '国庆节', isOffDay: true },
  { date: '2026-10-03', name: '国庆节', isOffDay: true },
  { date: '2026-10-04', name: '国庆节', isOffDay: true },
  { date: '2026-10-05', name: '国庆节', isOffDay: true },
  { date: '2026-10-06', name: '国庆节', isOffDay: true },
  { date: '2026-10-07', name: '国庆节', isOffDay: true },
  { date: '2026-10-08', name: '国庆节', isOffDay: true },
  { date: '2026-10-10', name: '国庆节调休', isOffDay: false },
];

const allHolidays = [...holidays2024, ...holidays2025, ...holidays2026];

export function getHolidayInfo(date: Date): Holiday | null {
  const dateStr = formatDate(date);
  return allHolidays.find(h => h.date === dateStr) || null;
}

function formatDate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}