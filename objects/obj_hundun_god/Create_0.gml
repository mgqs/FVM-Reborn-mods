event_inherited();
plant_id = "hundun_god";
obj_type = object_index;
current_level = 1;
event_user(0);

if (shape == 0)
{
	var _info = get_card_info_simple(plant_id);
	if (_info != false)
	{
		shape = _info.shape;
		if (current_level == 0)
			current_level = _info.level;
		if (skill == 0)
			skill = _info.skill;
	}
}

if (shape == 0)
	sprite_index = spr_hundun_god;
else if (shape == 1)
	sprite_index = spr_hundun_god_1;
else if (shape == 2)
	sprite_index = spr_hundun_god_2;
else if (shape == 3)
	sprite_index = spr_hundun_god_3;

flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
image_speed = 0;

// 帧布局（2026-10-28 用户，四种形态共用同一套动作长度）：
//   1-8 待机 / 9-19 吸食 / 20-29 食用 / 30-41 咀嚼 / 42-49 吞下
//   第 24 帧（0 起算 23）发射子弹
// 精灵帧数 55/56/57/53，均 ≥ 49，多余帧不播
f_idle_end = 7;             // 待机 0..7
f_suction_start = 8;        // 吸食 8..18
f_suction_end = 18;
f_eat = 19;                 // 食用 19..28
f_eat_end = 28;
f_chew_start = 29;          // 咀嚼 29..40（消化中循环）
f_chew_end = 40;
f_swallow_start = 41;       // 吞下 41..48
f_recover_end = 48;         // 播完回待机
f_shoot = 23;               // 第 24 帧发射
f_attack_start = f_suction_start;
f_attack_end = f_eat_end;
f_digest_end = f_chew_end;

// 消化时间 (digestion time) per star level, in frames (at 60fps)
// 35,34,33,32,31,30,28,26,24,22,20,18,16,13,10,7,4,3,2 seconds
var _digest_times = [2100, 2040, 1980, 1920, 1860, 1800, 1680, 1560, 1440, 1320, 1200, 1080, 960, 780, 600, 420, 240, 180, 120];
var _level_idx = clamp(current_level, 0, 18);
digest_time = _digest_times[_level_idx];
origin_digest_time = digest_time;
digest_timer = 0;
digest_timer_max = 0;
is_digesting = false;

anim_frame = 0;
attack_timer = 0;

target_enemy = [];
enemy_encounted = false;
enemy_hitted = false;

grid_range_col = 2;
grid_range_row = 2;
if (shape >= 1)
{
	grid_range_col = 3;
	grid_range_row = 3;
}
if (shape >= 2)
{
	grid_range_col = 3;
	grid_range_row = 4;
}
if (shape >= 3)
{
	grid_range_col = 2;
	grid_range_row = 3;
}

elite_damage = 4500;
if (shape == 1)
	elite_damage = 6000;
else if (shape == 2)
	elite_damage = 6000;
else if (shape >= 3)
	elite_damage = 9000;

explosion_range = 1.5 * global.grid_cell_size_x;
if (shape >= 1)
	explosion_range = 2.5 * global.grid_cell_size_x;

double_hit = true;
