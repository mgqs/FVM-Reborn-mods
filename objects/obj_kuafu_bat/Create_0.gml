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
// 2026-11-17 用户口径：变异蝙蝠鼠同样是定时刷新的干扰单位（跨服·梦魇天空），
//   不参与波次清场判定，没死光也能进下一波 / 结算。
wave_ignore = true

target_type = "air"

state = ENEMY_STATE.APPEAR
sprite_index = spr_kuafu_bat
special_ash = true
anim_timer = 0

target_col = -1
target_row = -1
banding_target_inst = noone

// 2026-11-18：整份照抄蝙蝠鼠（obj_bat_mouse）的形式 ——
//   Create 只管数据，不自己摆位置；
//   落点 / 配对 target / 出生高度全部交给 Step 里那段「自动补齐」，
//   由 obj_event_manager 的 kuafu_bat_spawn 按 bat_mouse_spawn 的同一写法成对创建（target + 蝙蝠）。
//   （旧写法在 Create 里改 x/y、Step 再拿 (x,y) 反推格子，两边算出的落点对不上，
//     蝙蝠会永远停在屏幕外，表现为「设置了变异蝙蝠但关卡里不出」。）
