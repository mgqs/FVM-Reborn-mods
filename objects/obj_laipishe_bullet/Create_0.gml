// 赖皮蛇海胆子弹 - 创建事件
damage = 0;
move_speed = 6;
target_type = "track";
damage_type = "normal";
hittable_types = get_hittable_enemy_types(target_type);

// 已命中的敌人ID列表，避免同一发子弹重复伤害同一目标
hitted_enemy = ds_list_create();

// 属主卡片引用
owner_card = noone;
start_col = 0;
start_row = 0;
bullet_shape = 0;

// 轨迹：向右飞往最右列，再返回卡片位置销毁
flying_out = true;
right_col = max(0, global.grid_cols - 1);

// 最大存活帧数兜底
max_life_frames = 900;
life_frames = 0;