// obj_fangkongmiao_bullet Step 事件
// 追踪最近的空军；命中后播命中特效（第 7~17 帧）再销毁；目标没了就直着飞出去，超时 / 出界销毁。
if (global.is_paused) exit;

// 命中特效段：停在命中位置播完再销毁（不再结算伤害、不再移动）
if (hitting)
{
    hit_t++;
    image_index = hit_first + min(hit_last - hit_first, hit_t div 3);
    if (hit_t >= (hit_last - hit_first + 1) * 3) instance_destroy();
    exit;
}

timer++;
// 0~5 飞行（1~6 帧），6 以后是爆炸段
image_index = (timer div 3) mod 6;

if (instance_exists(target_enemy) && target_enemy.hp > 0)
{
    var _tx = target_enemy.x;
    var _ty = target_enemy.y - 60;
    var _dir = point_direction(x, y, _tx, _ty);
    x += lengthdir_x(move_speed, _dir);
    y += lengthdir_y(move_speed, _dir);
    image_angle = 0;
}
else
{
    // 失去目标：在剩下的空军里重新找一只最近的
    var _best = noone;
    var _best_d = 99999;
    with (obj_enemy_parent)
    {
        if (hp <= 0) continue;
        if (!can_target_on(other.target_type, target_type)) continue;
        var _d = point_distance(other.x, other.y, x, y);
        if (_d < _best_d){ _best_d = _d; _best = id; }
    }
    target_enemy = _best;

    if (instance_exists(target_enemy))
    {
        var _dir2 = point_direction(x, y, target_enemy.x, target_enemy.y - 60);
        x += lengthdir_x(move_speed, _dir2);
        y += lengthdir_y(move_speed, _dir2);
    }
    else
    {
        x += move_speed;
    }
}

// 命中判定：只在目标身上判（对空弹不扫全屏）
if (instance_exists(target_enemy) && target_enemy.hp > 0 && precise_bbox_collision(id, target_enemy))
{
    var _e = target_enemy;
    var _dmg = damage;
    var _slow = slow_frames;

    with (_e)
    {
        damage_amount = _dmg;
        damage_type   = "normal";
        event_user(0);

        if (_slow > 0 && ice_timer < _slow) ice_timer = _slow;
    }

    audio_play_sound(snd_fire_hit, 0, 0);

    // 不立刻销毁：原地播命中特效（第 7~17 帧），播完由上面的特效段销毁
    hitting     = true;
    hit_t       = 0;
    image_index = hit_first;
    exit;
}

if (timer > max_life || x > 2400 || x < -300 || y > 1400 || y < -400)
{
    instance_destroy();
}
