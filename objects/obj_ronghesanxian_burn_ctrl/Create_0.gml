// obj_ronghesanxian_burn_ctrl（融合三线 · 燃烧结算控制器）
// 为什么独立成对象：卡片被铲掉（甚至卡片已不存在）时，已经在燃烧的老鼠仍要继续结算
// —— 与融合火盆的冰弹控制器 obj_ronghehuopen_ice_ctrl 是同一套思路。
// 由子弹命中时按需创建；列表空了 5 秒后自毁。
// 数据来源：「这组卡的推荐数值和情报岛.xlsx」——命中后 30% 概率每 1s 造成共 3 次[燃烧伤害]、可叠加。
burn_list = [];   // [{target: 老鼠实例id, ticks: 剩余结算次数, dmg: 每次[燃烧伤害], fx: 挂身火焰实例}]
tick_timer = 0;
idle_timer = 0;
