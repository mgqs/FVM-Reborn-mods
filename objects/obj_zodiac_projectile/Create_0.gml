kind = "wave";
row = 0;
burnt = false;
bounced = false;
damage = 0;
base_damage = 0;
star_splash_dmg = 0;      // 星星兔单格溅射那一跳的伤害（命中时算，with 里靠它传值）
shape = 0;
move_x = 8;
move_y = 0;
timer = 0;
hit_tick = 0;
_zodiac_candidates = [];
_sap_all = [];
_sap_out = [];
_sap_gen = -1;
target_id = noone;
hit_ids = [];
rows = 0;
center_row = 0;
cover_a = -1;  // 炎凰马子弹覆盖的行/列对（横向=行，竖向=列）
cover_b = -1;
vertical = false;
can_dandantu_store = false;
brazier_list = ds_list_create();
stored = false;      // 仙笛马飞马停靠状态：不移动、不计时、不碰撞
owner_id = noone;    // 停靠时跟随的宿主卡片
park_index = 0;      // 停靠层数（从下往上）
image_speed = 0.2;
// 固定轨迹类弹（炎凰马/御风马/仙笛马/粉姬马/归元马/星兔）穿地形障碍，
// 只影响 obj_obstacle 的拦截判定，不改变对老鼠的穿透次数。
pierce_obstacle = true;

// ── 环境交互（2026-11-10）：吃火 / 可反弹 + 需要的参数都在这里声明，碰撞事件由父类 obj_bullet_parent 统一处理
hazard_fire = { scale:0 };   // 星弹：五发斜射，只 fire/star 反弹
hazard_rebound = { axis:"move_x", judge:"none", kind_gate:true };   // 星弹：五发斜射，只 fire/star 反弹
