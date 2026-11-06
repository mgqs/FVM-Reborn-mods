if (global.is_paused) exit;
event_inherited();

if (is_frozen) exit;

live_timer++;
if (live_timer >= life_time){
    instance_destroy();          // 脚下光效会自己检测不到母体后销毁（见 obj_meiweijishiqi_effect 的 Step）
    exit
}

// 次数用完 → 隐形待着，等寿命到自然消失（时间神同款做法）
if (exec_count >= max_exec){
    if (image_alpha > 0) image_alpha = 0;
    exit
}

// 显示节奏（照 obj_time_god）：平时整卡隐形，只在快到执行时播待机动画。
//   第一次例外：刚放下就一直显示（播到 1.5 秒那次执行），否则放下瞬间有 0.25 秒看不见。
var _anim_play = idle_anim * flash_speed;              // 15 × 5 = 75 帧
if (exec_count == 0) _anim_play = first_delay;         // 首次：整段 1.5 秒都露着

exec_timer--;

if (exec_timer <= 0){
    // ── 到点：结算范围内正在冷却的实体卡 ──
    //   非实体卡走黑名单：时间神那份（brahma / ice_cream / magic_chicken / clotho / kuileima）
    //   再并上工程里其它「变化中、没有实体本体」的卡（蛇羹煲 / 百变蛇 / 星空穹马）
    //   自身和 player 也排除
    var _mb_blacklist = ["brahma", "ice_cream", "magic_chicken", "clotho", "kuileima",
                         "shegengbao", "baibianshe", "xingqiongma",
                         "meiweijishiqi", "player"];

    var _mc = grid_col;
    var _mr = grid_row;
    var _rc = range_col;
    var _rr = range_row;

    var _ids = ds_list_create();
    with (obj_card_parent){
        if (array_get_index(_mb_blacklist, plant_id) == -1
            && abs(grid_col - _mc) <= _rc && abs(grid_row - _mr) <= _rr){
            if (ds_list_find_index(_ids, plant_id) == -1) ds_list_add(_ids, plant_id);
        }
    }

    // 只对「正在冷却」的卡生效：已冷却完毕的（cooldown_timer >= cooldown）跳过
    //   减的幅度 = 总冷却 × 缩减比例（30% / 50% / 50%）
    with (obj_card_slot){
        if (cooldown_timer < cooldown && ds_list_find_index(_ids, card_id) != -1){
            var _cut = floor(cooldown * other.reduce_ratio);
            cooldown_timer = min(cooldown, cooldown_timer + _cut);
        }
    }
    ds_list_destroy(_ids);

    exec_count++;
    if (exec_count < max_exec) exec_timer = exec_gap;

    // 执行完立刻隐形，等下一轮快结束时再露头
    image_alpha = 0;
    image_index = 0;
    anim_frame  = 0;
    anim_tick   = 0;
    with (obj_meiweijishiqi_effect){
        if (parent_plant == other.id) image_alpha = 0;
    }
}
else if (exec_timer <= _anim_play){
    // ── 露头 + 播待机动画（循环，不会停住）──
    if (image_alpha == 0){
        image_alpha = 1;
        image_index = 0;
        anim_frame  = 0;
        anim_tick   = 0;
        with (obj_meiweijishiqi_effect){
            if (parent_plant == other.id) image_alpha = 1;
        }
    }

    if (anim_tick < flash_speed - 1){
        anim_tick++;
    }
    else{
        anim_tick = 0;
        anim_frame = (anim_frame + 1) mod (idle_anim + 1);
        image_index = anim_frame;
    }
}
else{
    // ── 冷却中：彻底不显示 ──
    if (image_alpha > 0){
        image_alpha = 0;
        image_index = 0;
        anim_frame  = 0;
        anim_tick   = 0;
        with (obj_meiweijishiqi_effect){
            if (parent_plant == other.id) image_alpha = 0;
        }
    }
}
