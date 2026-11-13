// obj_sheshejiu Step 事件
// ① 待机帧循环 ② 前摇到点 → 施法（Other_11）③ 持续时间到点 → 复原（Other_12 = event_user(2)）→ 自毁
if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

// ── 变星持续时长按技能档取（register_card_skill "升降持续"，单位秒 → ×60 转帧；Create 时 skill 还没赋，所以放第一帧）──
if (!ss_init_done){
    ss_init_done = true;

    var _sk   = variable_instance_exists(id, "skill") ? clamp(skill, 0, 8) : 0;
    var _info = get_plant_data_with_skill("sheshejiu", shape, clamp(current_level, 0, 16), _sk);
    if (_info != undefined && ds_map_exists(_info, "升降持续")){
        ss_live_frames = round(_info[? "升降持续"] * 60);   // 技能表存的是秒
    }
}

// ── 统一时间轴（2026-11-13 重写）：前摇 66 帧 → 倒酒 11~18 帧 → 消失 ──
//   旧写法靠 ss_pouring / ss_pour_i 多个状态位互相配合，一旦某帧没推进就永远停在那一帧；
//   现在所有帧号都由 ss_t 算出来，只要 Step 在跑就一定往前走。
ss_t++;

if (!ss_cast_done && ss_t >= ss_cast_delay){
    ss_cast_done  = true;
    ss_rest_timer = 0;
    ss_pouring    = true;
    event_user(1);                 // 效果在施法那一刻生效
}

if (!ss_cast_done){
    // 前摇：把 0~10 这 11 帧**均摊**到整个前摇长度上（66/11 = 6 帧一张）
    //   2026-11-13：原来按 flash_speed=5 算，55 帧就走完 11 帧，剩下 11 帧死停在最后一帧
    //   → 看着就是「倒酒前卡一下」。均摊后最后一帧正好在前摇结束那一刻，无停顿。
    var _idle_frames = max(1, ss_anim_to - ss_anim_from + 1);
    var _idle_step   = max(1, ceil(ss_cast_delay / _idle_frames));
    image_index = min(ss_anim_to, ss_anim_from + floor(ss_t / _idle_step));
    exit;
}

if (!ss_gone){
    var _pi = ss_pour_from + floor((ss_t - ss_cast_delay) / flash_speed);
    if (_pi > ss_pour_to){
        ss_gone = true;
        card_destroyed(id);        // 只摘网格引用，不触发回收/死亡效果（同百变蛇）
        // 一次性卡消失后星级图标还留在场上 —— 它是父对象挂的 banding_star_obj，visible=false 带不走
        if (instance_exists(banding_star_obj)) instance_destroy(banding_star_obj);
        banding_star_obj = noone;
        visible = false;
        exit;
    }
    image_index = _pi;
    exit;
}

// ── ③ 持续时间到点 → 复原 ──
ss_rest_timer++;
if (ss_rest_timer >= ss_live_frames){
    event_user(2);
    if (ds_exists(ss_snap, ds_type_list)) ds_list_destroy(ss_snap);
    instance_destroy();
}
