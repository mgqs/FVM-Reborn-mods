event_inherited();
plant_id = "sheng_huo";
obj_type = object_index;
current_level = 1;
cluster_multiplier = 1;
event_user(0);

if (shape == 0)
    sprite_index = spr_sh;
else if (shape == 1)
    sprite_index = spr_sh_1;
else if (shape == 2)
    sprite_index = spr_sh_2;
else if (shape == 3)
    sprite_index = spr_sh_3;

attack_anim = 9;
idle_anim = 10;
flash_speed = 5;
plant_type = "normal";
target_type = "pierce";
is_slowdown = false;
awake_anim = 0;
anim_timer = 0;
base_atk = atk;

// ── 攻击口径（Step_0 索敌读 sh_hittable）──
//   0/1 转：陆鼠 + 非主流·高跷 + 障碍 + 幽灵鼠
//   2/3 转：再加 空军 + 地鼠军；不含潜水鼠（所以不能用 all）
if (shape >= 2){
    target_type = "all";          // 仅用于敌人侧读取；实际可打看 sh_hittable
    sh_hittable = ["normal", "dance", "obstacle", "invisible", "air", "underground"];
    sh_dig_ok   = true;
} else {
    target_type = "pierce";
    sh_hittable = ["normal", "dance", "obstacle", "invisible"];
    sh_dig_ok   = false;
}

