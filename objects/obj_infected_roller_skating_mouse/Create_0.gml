event_inherited();
atk = 20;
hp = 3000;
maxhp = 3000;
helmet_hp = 2280;
helmet_max_hp = 2280;
move_anim = 10;
attack_anim = 6;
// 无头盔图共 41 帧：待机/移动 0..19、攻击 20..31、死亡 32..40 → 死亡只有 9 帧。
// 原来写 13 会让父类的淡出阈值算到索引 44（超出 40），image_index 永远够不到 → 尸体不消失。
death_anim = 9;
move_speed = 0.6;
armor_dropped = false;
immune_to_ash = true;
arm_dropped = false;
