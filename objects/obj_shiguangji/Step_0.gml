// obj_shiguangji Step 事件
// ① 帧循环 ② 前摇到点 → 施法（Other_11）③ 星光播完（约 0.6 秒）→ 自毁
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 前摇按技能档取（Create 时 skill 还没赋）──
if (!sg_init_done){
    sg_init_done = true;

    var _sk   = variable_instance_exists(id, "skill") ? clamp(skill, 0, 8) : 0;
    var _info = get_plant_data_with_skill("shiguangji", shape, clamp(current_level, 0, 16), _sk);
    if (_info != undefined && ds_map_exists(_info, "前摇")){
        sg_cast_delay = round(_info[? "前摇"] * 60);
    }
}

// ── ① 帧循环 ──
sg_anim_tick++;
if (sg_anim_tick >= flash_speed){
    sg_anim_tick = 0;
    sg_anim_i++;
    if (sg_anim_i > sg_anim_to) sg_anim_i = sg_anim_from;
}
image_index = sg_anim_i;      // 每帧都写：父对象也在推帧

// ── ② 前摇 ──
if (!sg_cast_done){
    sg_timer++;
    if (sg_timer >= sg_cast_delay){
        sg_cast_done = true;
        event_user(1);
    }
    exit;
}

// ── ③ 施法后收尾：给星光一点时间再消失 ──
sg_end_timer++;
if (sg_end_timer >= 36){
    instance_destroy();
}
