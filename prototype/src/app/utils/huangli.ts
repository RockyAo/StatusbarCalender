// 黄历数据工具

// 天干
const TIAN_GAN = ['甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'];

// 地支
const DI_ZHI = ['子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'];

// 生肖
const ZODIAC = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];

// 五行
const WU_XING = ['金', '木', '水', '火', '土'];

// 建除十二神
const JIAN_CHU = ['建', '除', '满', '平', '定', '执', '破', '危', '成', '收', '开', '闭'];

// 宜忌事项
const YI_JI_ITEMS = [
  '嫁娶', '祭祀', '开光', '祈福', '求嗣', '出行', '解除', '伐木', 
  '搬家', '入宅', '移徙', '安床', '开市', '交易', '立券', '纳财',
  '栽种', '纳畜', '牧养', '动土', '破土', '安葬', '修造', '装修',
  '出火', '进人口', '挂匾', '会亲友', '竖柱', '上梁', '订盟', '纳采'
];

export interface HuangliInfo {
  ganZhi: string;        // 干支纪日
  zodiac: string;        // 生肖
  wuXing: string;        // 五行
  jianChu: string;       // 建除
  chong: string;         // 冲煞
  yi: string[];          // 宜
  ji: string[];          // 忌
  taiShen: string;       // 胎神占方
}

/**
 * 获取黄历信息
 */
export function getHuangliInfo(date: Date): HuangliInfo {
  const dayOffset = getDayOffset(date);
  const yearOffset = date.getFullYear() - 1900;
  
  // 计算干支
  const ganIndex = (dayOffset + 10) % 10;
  const zhiIndex = (dayOffset + 12) % 12;
  const ganZhi = TIAN_GAN[ganIndex] + DI_ZHI[zhiIndex];
  
  // 生肖（根据地支）
  const zodiac = ZODIAC[zhiIndex];
  
  // 五行（简化算法，根据干支纳音）
  const wuXing = getWuXing(ganIndex, zhiIndex);
  
  // 建除（简化算法）
  const jianChu = JIAN_CHU[dayOffset % 12];
  
  // 冲煞（地支相冲）
  const chongZhiIndex = (zhiIndex + 6) % 12;
  const chong = `冲${ZODIAC[chongZhiIndex]}`;
  
  // 宜忌（根据日期简化算法）
  const { yi, ji } = getYiJi(dayOffset, jianChu);
  
  // 胎神占方（简化）
  const taiShen = getTaiShen(dayOffset);
  
  return {
    ganZhi,
    zodiac,
    wuXing,
    jianChu,
    chong,
    yi,
    ji,
    taiShen
  };
}

/**
 * 计算从1900年1月1日到指定日期的天数偏移
 */
function getDayOffset(date: Date): number {
  const baseDate = new Date(1900, 0, 1);
  const diff = date.getTime() - baseDate.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24));
}

/**
 * 获取五行（简化算法）
 */
function getWuXing(ganIndex: number, zhiIndex: number): string {
  const wuXingTable = [
    ['海中金', '炉中火', '大林木', '路旁土', '剑锋金'],
    ['山头火', '涧下水', '城头土', '白蜡金', '杨柳木'],
    ['泉中水', '屋上土', '霹雳火', '松柏木', '长流水'],
    ['沙中金', '山下火', '平地木', '壁上土', '金箔金'],
    ['覆灯火', '天河水', '大驿土', '钗钏金', '桑柘木'],
    ['大溪水', '沙中土', '天上火', '石榴木', '大海水']
  ];
  
  const index = Math.floor((ganIndex * 6 + zhiIndex) % 30 / 5);
  const subIndex = (ganIndex * 6 + zhiIndex) % 5;
  return wuXingTable[index]?.[subIndex] || '金';
}

/**
 * 获取宜忌（简化算法）
 */
function getYiJi(dayOffset: number, jianChu: string): { yi: string[], ji: string[] } {
  const seed = dayOffset;
  const yi: string[] = [];
  const ji: string[] = [];
  
  // 根据建除确定基本宜忌
  const yiBase = getYiByJianChu(jianChu);
  const jiBase = getJiByJianChu(jianChu);
  
  // 随机选择3-5个宜和忌
  const yiCount = 3 + (seed % 3);
  const jiCount = 3 + ((seed + 1) % 3);
  
  for (let i = 0; i < yiCount; i++) {
    const index = (seed + i * 7) % yiBase.length;
    if (!yi.includes(yiBase[index])) {
      yi.push(yiBase[index]);
    }
  }
  
  for (let i = 0; i < jiCount; i++) {
    const index = (seed + i * 11) % jiBase.length;
    if (!ji.includes(jiBase[index]) && !yi.includes(jiBase[index])) {
      ji.push(jiBase[index]);
    }
  }
  
  return { yi, ji };
}

/**
 * 根据建除获取适宜的事项
 */
function getYiByJianChu(jianChu: string): string[] {
  const yiMap: { [key: string]: string[] } = {
    '建': ['祭祀', '祈福', '求嗣', '订盟', '纳采'],
    '除': ['沐浴', '扫舍', '解除', '求医', '治病'],
    '满': ['祭祀', '祈福', '纳财', '开市', '交易'],
    '平': ['祭祀', '修造', '装修', '栽种', '纳畜'],
    '定': ['嫁娶', '移徙', '入宅', '安床', '开市'],
    '执': ['祭祀', '祈福', '求嗣', '嫁娶', '订盟'],
    '破': ['破土', '拆卸', '求医', '治病'],
    '危': ['安床', '修造', '装修', '动土'],
    '成': ['嫁娶', '开市', '交易', '纳财', '立券'],
    '收': ['纳财', '开市', '交易', '纳畜', '栽种'],
    '开': ['祭祀', '祈福', '开光', '嫁娶', '出行', '开市', '交易'],
    '闭': ['修造', '装修', '补垣', '塞穴']
  };
  return yiMap[jianChu] || ['祭祀', '祈福'];
}

/**
 * 根据建除获取忌讳的事项
 */
function getJiByJianChu(jianChu: string): string[] {
  const jiMap: { [key: string]: string[] } = {
    '建': ['动土', '开仓', '出货财'],
    '除': ['嫁娶', '移徙', '入宅'],
    '满': ['栽种', '安葬'],
    '平': ['破土', '安葬'],
    '定': ['词讼', '出行'],
    '执': ['开市', '求财'],
    '破': ['嫁娶', '祭祀', '祈福', '开市', '安葬'],
    '危': ['出行', '登高'],
    '成': ['安葬', '破土'],
    '收': ['开市', '出行'],
    '开': ['安葬', '破土'],
    '闭': ['出行', '开市', '求财']
  };
  return jiMap[jianChu] || ['诸事不宜'];
}

/**
 * 获取胎神占方（简化）
 */
function getTaiShen(dayOffset: number): string {
  const positions = [
    '占门碓', '碓磨门', '厨灶炉', '仓库门', '房床厕',
    '占门床', '占碓磨', '厨灶厕', '仓库碓', '房床门',
    '门鸡栖', '碓磨栖', '厨灶床', '仓库炉', '房床碓',
    '占门厕', '碓磨厕', '厨灶门', '仓库床', '占大门'
  ];
  
  const directions = ['外东南', '外正南', '外西南', '外正西', '外西北', '外正北', '外东北', '外正东', '房内南', '房内北'];
  
  const posIndex = dayOffset % positions.length;
  const dirIndex = dayOffset % directions.length;
  
  return `${positions[posIndex]}${directions[dirIndex]}`;
}
