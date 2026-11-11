// Inherit the parent event
event_inherited();

timer = 0
hp = 5400
maxhp = 5400
state = "appear"
anim_wait = 90
special_ash = true
mouse_id = "kf_zrb_jack_rock_skill_4"
move_speed = 2

// 滚石速度（每帧左移像素数）：与暴躁杰克的滚石保持一致，统一为 1。
// 曾经为了「变异版更强」改成 2，但位移翻倍会让滚石走位比其它行快一倍，
// 与技能描述的「滚石」手感不符，也容易在第四列消失前多吃一整格，故归一化。
rock_speed = 1

prev_spr = spr_kf_zrb_jack_head_skill_3
next_spr = spr_kf_zrb_jack_head_skill_4

immune_to_ash = true