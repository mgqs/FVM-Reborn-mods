// 通用冰冻区域：变异钢爪皮特（踩踏 3*3）/ 变异酷帅小明（冰爆 5*5）
// 由 BOSS 技能创建，创建后每一帧扫描范围内卡片并施加冰冻（等同冰企鹅炸弹）
// 视觉：循环播放小明冰雾特效（spr_xiaoming_ice），持续存在的冰雾比纯色矩形明显得多
ice_radius = 1          // 半径（格）：1 = 3*3，2 = 5*5
ice_life   = 300        // 持续帧数，之后淡出
ice_col    = -1         // 区域中心格（-1 表示只用世界坐标判定）
ice_row    = -1
timer      = 0
image_alpha = 1

sprite_index = spr_xiaoming_ice
image_speed  = 0        // 本对象没有 Draw 的自动绘制，动画索引手动推进
anim_index   = 0
anim_speed   = 0.45
