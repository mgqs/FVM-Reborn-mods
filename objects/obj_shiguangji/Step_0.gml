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

// ── ① 帧循环（前摇待机 0~9）──
if (sg_play == 0){
    sg_anim_tick++;
    if (sg_anim_tick >= flash_speed){
        sg_anim_tick = 0;
        sg_anim_i++;
        if (sg_anim_i > sg_idle_to) sg_anim_i = sg_idle_from;
    }
    image_index = sg_anim_i;      // 每帧都写：父对象也在推帧
}

// ── ② 前摇 → 施法（生效）+ 选升/降星演出 ──
if (!sg_cast_done){
    sg_timer++;
    if (sg_timer >= sg_cast_delay){
        sg_cast_done = true;
        event_user(1);                                       // 效果立刻生效，并把净星数记进 sg_net
        sg_play = (sg_net >= 0) ? 1 : -1;                    // 净升/净降决定播哪一段
        sg_anim_i = (sg_play == 1) ? sg_up_from : sg_down_to;
        sg_anim_tick = 0;
    }
    exit;
}

// ── ③ 演出：升星 10→19；降星 30→20（倒转）；播完自毁 ──
if (!sg_anim_done){
    sg_anim_tick++;
    if (sg_anim_tick >= flash_speed){
        sg_anim_tick = 0;
        sg_anim_i += (sg_play == 1) ? 1 : -1;
    }
    image_index = sg_anim_i;

    var _fin = (sg_play == 1) ? (sg_anim_i > sg_up_to) : (sg_anim_i < sg_down_from);
    if (_fin){
        sg_anim_done = true;
        instance_destroy();
    }
}
