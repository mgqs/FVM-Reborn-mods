/// 陆地（奶盖桥岩浆轨道占位）：初始时这些格子视为 normal（可放卡），
/// 触发后切换为下沉动画、销毁并交由 Destroy 事件创建真正的 obj_lava。
/// 由 obj_battle 解析 JSON object 数组自动创建，ludi_track 由注册表指定。
col = -1;
row = -1;
ludi_track = 0;          // 1 = 红轨道（小兵第 3 波触发） / 2 = 黄轨道（首个 BOSS 波触发）
ludi_triggered = false;

sprite_index = spr_ludi_idel;
image_speed = 0.15;
image_index = 0;
image_xscale = 2;
image_yscale = 2;
// 卡片/敌人 depth 为 -10~-320，龙柱为 49，地图为 50
// 取 49.5：在卡片之下、龙柱之下、地图之上，既不遮卡片也不遮龙柱
depth = 49.5;
