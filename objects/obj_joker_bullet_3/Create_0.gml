// 终转弹：穿透老鼠与障碍（pierce_all 只给障碍 Script 放行用，target_type 仍是 air）
damage = 0;
move_speed = 0;
row = 0;
damage_type = "normal";
target_type = "air";        // 空中 + 陆地；潜水 / 地下见 hittable_types（天蝎座复刻走这里的默认值）
shape = 0;
hitted_enemy = -4;
image_xscale = 1.4;
image_yscale = 1.4;
hittable_types = ["normal", "air", "underground", "diver"];
hit_tick = 0;
splash_ratio = 1;   // 命中后 3x3 溅射倍率（卡片 Other_11 会按 custom 覆写）

// ── 终转穿透：命中不消失，继续往前飞；同一只只结算一次，每命中一只就地做 3x3 溅射 ──
pierce_all = true;
hit_log = ds_list_create();
splash_cx = 0;
splash_excl = -4;
