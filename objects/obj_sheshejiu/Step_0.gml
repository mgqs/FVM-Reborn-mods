// obj_sheshejiu Step 事件
// ① 待机帧循环 ② 前摇到点 → 施法（Other_11）③ 持续时间到点 → 复原（Other_12 = event_user(2)）→ 自毁
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 持续时间按技能档取（Create 时 skill 还没赋，所以放第一帧）──
if (!ss_init_done){
    ss_init_done = true;

    var _sk   = variable_instance_exists(id, "skill") ? clamp(skill, 0, 8) : 0;
    var _info = get_plant_data_with_skill("sheshejiu", shape, clamp(current_level, 0, 16), _sk);
    if (_info != undefined && ds_map_exists(_info, "持续时间")){
        ss_live_frames = round(_info[? "持续时间"] * 60);
    }
}

// ── ① 待机帧（在 [from..to] 里循环）──
ss_anim_tick++;
if (ss_anim_tick >= flash_speed){
    ss_anim_tick = 0;
    ss_anim_i++;
    if (ss_anim_i > ss_anim_to) ss_anim_i = ss_anim_from;
}
image_index = ss_anim_i;      // 每帧都写：父对象也在推帧，只在自己这一步写会被它顶回去

// ── ② 前摇 → 施法 ──
if (!ss_cast_done){
    ss_timer++;
    if (ss_timer >= ss_cast_delay){
        ss_cast_done  = true;
        ss_rest_timer = 0;
        event_user(1);
    }
    exit;
}

// ── ③ 持续时间到点 → 复原 ──
ss_rest_timer++;
if (ss_rest_timer >= ss_live_frames){
    event_user(2);
    if (ds_exists(ss_snap, ds_type_list)) ds_list_destroy(ss_snap);
    instance_destroy();
}
