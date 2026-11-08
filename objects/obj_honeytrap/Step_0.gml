// obj_honeytrap Step 事件
// 攒蜜蜂 → 攒满一次放飞（先 BOSS，再当前血量最高的）。没有目标就继续停靠等下一轮。
if (global.is_paused) exit;

// 同格去重：不占格的卡走 can_place_at_position 的 gridless 分支（直接放行），
//   同格能无限叠 → 放第二张时把旧的那张清掉（与麦芽糖 obj_maiya 完全一致）
remove_timer++;
if (remove_timer == 1)
{
    with (obj_card_parent)
    {
        if (grid_row == other.grid_row && grid_col == other.grid_col
            && plant_id == "honeytrap" && id != other.id)
        {
            instance_destroy();
        }
    }
}

event_inherited();

if (hp <= 0) exit;
if (is_frozen || state == CARD_STATE.SLEEP) exit;

attack_timer++;
if (attack_timer < cycle / 3) exit;

attack_timer = 0;

// 攒 1 只
if (array_length(bees) < max_bees)
{
    var _b = instance_create_depth(x + 24, y - 8 - array_length(bees) * 16, depth - 500, obj_honeytrap_bee);
    _b.stored     = true;
    _b.damage     = atk;
    _b.boss_mult  = boss_mult;
    _b.owner_id   = id;
    _b.target_id  = noone;
    _b.park_index = array_length(bees);

    array_push(bees, _b);
}

// 攒满 → 放飞
if (array_length(bees) >= max_bees)
{
    var _t = noone;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        // 集火口径按卡自己的 target_type（track = 普通 / 潜水 / 空军）；
        //   2026-11-08 用户口径：范围/锁定都要按类型过滤，不再无差别锁任何敌人
        if (!can_target_on(other.target_type, target_type)) continue;
        if (!instance_exists(_t) || (is_boss && !_t.is_boss)
            || (is_boss == _t.is_boss && hp > _t.hp))
            _t = id;
    }
    // 傀儡马分身也算（同仙笛马）
    if (instance_exists(obj_kuileima_decoy))
    {
        with (obj_kuileima_decoy)
        {
            if (hp > 0 && (!instance_exists(_t) || hp > _t.hp)) _t = id;
        }
    }

    if (instance_exists(_t))
    {
        for (var _i = 0; _i < array_length(bees); _i++)
        {
            var _bb = bees[_i];
            if (!instance_exists(_bb)) continue;
            _bb.stored    = false;
            _bb.target_id = _t;
            _bb.owner_id  = id;
        }
        bees = [];
    }
}
