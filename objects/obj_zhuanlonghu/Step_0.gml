// obj_zhuanlonghu Step 事件
// ① 待机帧 ② 前摇到点 → 减冷却（Other_11）→ 自毁
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 首次 Step 取数值（冷却缩减是 custom 标量，前摇按技能档）──
if (!zl_init_done){
    zl_init_done = true;

    var _sk   = variable_instance_exists(id, "skill") ? clamp(skill, 0, 8) : 0;
    var _info = get_plant_data_with_skill("zhuanlonghu", shape, clamp(current_level, 0, 16), _sk);

    if (_info != undefined && ds_map_exists(_info, "冷却缩减")){
        zl_reduce_pct   = _info[? "冷却缩减"];
        zl_reduce_ratio = zl_reduce_pct / 100;
    }
    if (_info != undefined && ds_map_exists(_info, "前摇")){
        zl_cast_delay = round(_info[? "前摇"] * 60);
    }
}

// ── ① 待机帧 ──
zl_anim_tick++;
if (zl_anim_tick >= flash_speed){
    zl_anim_tick = 0;
    zl_anim_i++;
    if (zl_anim_i > idle_anim) zl_anim_i = 0;
}
image_index = zl_anim_i;      // 每帧都写：父对象也在推帧

// ── ② 前摇 ──
if (zl_cast_done) exit;

zl_timer++;
if (zl_timer >= zl_cast_delay){
    zl_cast_done = true;
    event_user(1);
    instance_destroy();
}
