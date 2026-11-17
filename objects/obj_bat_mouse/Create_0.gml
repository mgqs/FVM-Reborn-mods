 // Inherit the parent event
event_inherited();
hp = 800
maxhp = 800
move_anim = 8
attack_anim = 4
death_anim = 12
move_speed = 0
mouse_id = "bat_mouse"
attack_range = 90
// 2026-11-17 用户口径：蝙蝠鼠是 obj_event_manager 按 interval 定时刷的干扰单位，
//   没死光也应当能进入下一波 / 结算 —— 否则它赖在场上会一直卡住清场判定。
wave_ignore = true

target_type = "air"

state = ENEMY_STATE.APPEAR
sprite_index = spr_bat_mouse
special_ash = true
anim_timer = 0

target_col = -1
target_row = -1
banding_target_inst = noone