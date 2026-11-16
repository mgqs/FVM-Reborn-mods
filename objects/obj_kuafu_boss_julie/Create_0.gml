// Inherit the parent event
event_inherited();

mouse_id = "kuafu_boss_julie"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 50000
maxhp = 50000
immune_to_ash = true
wait_time = 240
cave = noone
sprite_index = spr_kuafu_boss_julie_idle
idle_spr = spr_kuafu_boss_julie_idle
idle_anim = 12
is_boss = true

y_move_speed = 0
x_move = 0

fog_summoned = false
banding_summon_obj = noone

skill_choose = 0
skill_count = 0
image_alpha = 0
appear = false
avaliable_pos = ds_list_create()
missle_coord = []

hpbar_inst = instance_create_depth(450,1040,-900,obj_boss_hpbar)
hpbar_inst.target_boss = id
hpbar_inst.boss_id = mouse_id

if obj_battle.boss_count > 0{
	hpbar_inst.y -= 40
}

// 变异护盾：落地召唤变异中尉/加血期间展开，非投掷卡片减伤 60%（判定抄牡蛎鼠 damage_type != "throw"）
shield_active = false
shield_anim = 0
shield_spr = spr_kuafu_boss_shield
shield_take_mult = 0.4
// 绘制位置/缩放：朱莉朝左，护盾挡在身前（屏幕左侧）。
// 按 239x175 立绘、origin(110,169) 折算：护盾整体落在身体左侧、与左翼轻微重叠，
// 高约覆盖头部到腹部（对照用户给的参考图）。
shield_dx = -130
shield_dy = -100
shield_sx = 1.05
shield_sy = 1.12
// 技能动画结束后护盾继续保留的帧数：覆盖召唤的中尉落地 + 加血余波，
// 否则技能一播完护盾就消失，等于减伤时间被掐短。
shield_tail = 120
shield_hold = 0
