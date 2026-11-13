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

// ── ① 转圈：帧号 = 前摇进度 ──
//   🔴 不能再用「每 flash_speed 帧 +1 然后回绕」：前摇 90 帧、一圈 16 帧 ×5 = 80 帧，
//      到点时会卡在第二圈第 2 帧，观感就是「转完一圈又冒出来转一圈」。
//      绑定进度后，前摇到点 = 正好转到最后一帧。
var _prog = (zl_cast_delay > 0) ? min(1, zl_timer / zl_cast_delay) : 1;
zl_anim_i = min(idle_anim, floor(_prog * (idle_anim + 1)));
image_index = zl_anim_i;      // 每帧都写：父对象也在推帧

// ── ② 前摇 ──
if (zl_cast_done)
{
    // 生效已在到点那一帧发过（event_user(1)）；这里只留一个收尾停顿，不再转第二圈
    zl_tail++;
    if (zl_tail >= 6) instance_destroy();
    exit;
}

zl_timer++;
if (zl_timer >= zl_cast_delay){
    zl_cast_done = true;
    event_user(1);            // 生效（减冷却）
}
