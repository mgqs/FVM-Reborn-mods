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

// ── ① 前摇演出：把第 2~10 帧**均摊**到整段前摇上，播一遍就停，不再循环 ──
//   2026-11-13 用户口径：一次性卡不该「原地待机转圈」——
//   前摇走完那一刻出效果，中间这段就是它的前摇演出（写法同蛇蛇酒）。
//   原来按 flash_speed=5 播，9 帧只要 45 帧，而前摇 162 帧（2.7 秒）→ 会循环 3~4 圈。
if (sg_play == 0){
    var _idle_n    = max(1, sg_idle_to - sg_idle_from + 1);
    var _idle_step = max(1, ceil(sg_cast_delay / _idle_n));
    sg_anim_i   = min(sg_idle_to, sg_idle_from + floor(sg_timer / _idle_step));
    image_index = sg_anim_i;      // 每帧都写：父对象也在推帧
}

// ── ② 前摇 → 施法（生效）+ 选升/降星演出 ──
if (!sg_cast_done){
    sg_timer++;
    if (sg_timer >= sg_cast_delay){
        sg_cast_done = true;
        event_user(1);                                       // 效果立刻生效，并把净星数记进 sg_net
        sg_play = (sg_net >= 0) ? 1 : -1;                    // 净升/净降决定播哪一段
        // 升星从第 11 帧起（10）；降星从第 21 帧起（20），两段都是正着播
        sg_anim_i = (sg_play == 1) ? sg_up_from : sg_down_from;
        sg_anim_tick = 0;
        image_index = sg_anim_i;      // 同帧就切到演出首帧，避免父对象那一帧推出来的空挡帧闪一下
    }
    exit;
}

// ── ③ 演出：升星 10→19；降星 20→30；都是正向播，播完自毁 ──
if (!sg_anim_done){
    sg_anim_tick++;
    if (sg_anim_tick >= flash_speed){
        sg_anim_tick = 0;
        sg_anim_i++;
    }
    image_index = sg_anim_i;

    var _end = (sg_play == 1) ? sg_up_to : sg_down_to;
    var _fin = (sg_anim_i > _end);
    if (_fin){
        sg_anim_done = true;
        instance_destroy();
    }
}
