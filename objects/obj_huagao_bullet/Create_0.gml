// 灯影花糕的魂虫：沿固定轨迹直线飞行（横向左右 / 竖向下落）
event_inherited();
can_dandantu_store = false;

owner_id = noone;
shape = 0;
damage = 0;
base_damage = 0;
dir = 1;              // 1 向右 / -1 向左（vertical 时忽略）
vertical = false;
rows = [];            // 横向覆盖的行
cols = [];            // 竖向覆盖的列
mid_row = 0;
hits_mid = 2;         // 中路敌人的受击次数
hits_side = 1;        // 上下路敌人的受击次数
hit_ids = [];
life = 0;
// 同一次攻击的所有魂虫共用一个标记：保证每只敌人每次攻击只被结算一次
attack_tag = 0;
// 注意：不要用内置变量 speed —— 它会让引擎每帧按 direction 自动位移，
// 与 Step 里的手动位移叠加（右飞翻倍、左飞相互抵消原地不动）。这里用自定义变量。
huagao_speed = 8;
speed = 0;
hspeed = 0;
vspeed = 0;
image_speed = 0.3;
image_angle = 0;
