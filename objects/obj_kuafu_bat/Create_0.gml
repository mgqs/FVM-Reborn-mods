 // Inherit the parent event
event_inherited();
hp = 880
maxhp = 880
move_anim = 8
attack_anim = 4
death_anim = 12
move_speed = 0
immune_to_ash = true
mouse_id = "kuafu_bat"
attack_range = 90

target_type = "air"

state = ENEMY_STATE.APPEAR
sprite_index = spr_kuafu_bat
special_ash = true
anim_timer = 0

target_col = -1
target_row = -1
banding_target_inst = noone
move_anim = 8
attack_anim = 4
death_anim = 12

// 变异：蝙蝠僵尸鼠随机出现在地图内的某一列上空
// 通用生成器把敌人固定刷在第 10 列（col 9 起），这只不动且吊绳，会永远堆在最右侧，
// 所以这里把出生列洗成地图内的随机一列，行保持不变（行由生成器决定，避开空行）
var _rand_col = irandom_range(0, global.grid_cols - 1)
x = get_world_position_from_grid(_rand_col, 0).x + 30
