event_inherited();
plant_id = "shennong_god";
event_user(0);

if (shape == 0)
    sprite_index = spr_shennong_god;
else if (shape == 1)
    sprite_index = spr_shennong_god_1;
else if (shape == 2)
    sprite_index = spr_shennong_god_2;
else
    sprite_index = spr_shennong_god_3;   // 终转（至尊炎帝）

attack_anim = 12;   // 攻击动画12帧（第14-25帧，索引13-24）
idle_anim = 12;     // 闲置动画13帧（第1-13帧，索引0-12）
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
target_type = "all"; // 可攻击所有类型：地面、空中、地下等
uses_fire_frame = true; // 出弹绑动画帧：cycle 被压小时由 obj_card_parent 压缩动画步长

// 炎帝使用自定义攻击循环，计时器必须在创建时初始化。
attack_timer = 0;
cooldown_timer = 0;

// 终转（shape 3）：场上炎帝 > 7 只时，攻击力最高的 1 只在 7.5 / 8.5 列 0 行
// 每 5 秒各召唤 1 发竖向陨焰，向下攻击 7~9 列（分别受击 1/2/1 次）。
// 判定用「本帧是否轮到我」，见 Step_0.gml。
vburst_timer = 0;
is_top_attacker = false;
