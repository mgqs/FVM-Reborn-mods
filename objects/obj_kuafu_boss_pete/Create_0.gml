// Inherit the parent event
event_inherited();

mouse_id = "kuafu_boss_pete"
jump_times = 0
state = BOSS_STATE.APPEAR
hp = 40000
maxhp = 40000
immune_to_ash = true
wait_time = 300
cave = noone
sprite_index = spr_kuafu_boss_pete_appear
is_boss = true

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

// 变异护盾：释放钢爪/导弹/尖刺期间展开，非投掷卡片减伤 50%（判定抄牡蛎鼠 damage_type != "throw"）
shield_active = false
shield_anim = 0
shield_spr = spr_kuafu_boss_shield
shield_take_mult = 0.5
// 绘制位置/缩放：按 271x296 立绘、origin(74,290) 折算的身形中心
shield_dx = 60
shield_dy = -145
shield_sx = 2.0
shield_sy = 1.45
