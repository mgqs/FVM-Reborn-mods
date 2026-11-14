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
// 绘制位置/缩放：按 239x175 立绘、origin(110,169) 折算的身形中心（暂用皮特同款护盾素材）
shield_dx = 10
shield_dy = -82
shield_sx = 1.8
shield_sy = 1.0
