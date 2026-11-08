// obj_huanyingshe Step 事件
// 前方（上下 row_span 行、右侧）有敌开火。
if (global.is_paused) exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP || hp <= 0) exit;

// 攻击段：播到 fire_frame（第 20 帧 = 蛋离嘴）才出弹；播完回待机
//   帧由父对象按 idle_anim / attack_anim 推（event_inherited 已经推过本帧）
if (state == CARD_STATE.ATTACK)
{
    anim_t++;
    if (!huanyingshe_fired && image_index >= fire_frame)
    {
        huanyingshe_fired = true;
        event_user(1);
    }
    if (anim_t >= attack_anim * flash_speed)
    {
        anim_t = 0;
        state = CARD_STATE.IDLE;
        image_index = 0;
    }
}

var _has_enemy = false;
with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (abs(grid_row - other.grid_row) > other.row_span) continue;
    if (grid_col < other.grid_col) continue;
    if (grid_col > global.grid_cols + 1) continue;
    if (!can_target_on(other.target_type, target_type)) continue;

    _has_enemy = true;
    break;
}

if (_has_enemy)
{
    attack_timer++;
    if (attack_timer >= cycle)
    {
        attack_timer = 0;
        state = CARD_STATE.ATTACK;
        anim_t = 0;
        huanyingshe_fired = false;   // 子弹留到第 20 帧（蛋离嘴）才出，见上面的攻击段
        image_index = idle_anim + 1;
    }
}
else
{
    attack_timer = 0;
}
