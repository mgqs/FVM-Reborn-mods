// obj_doumaobang_cat Step 事件
// 照贪吃兔 / 白羊座的冲撞口径：能撞飞的直接撞飞（特效 + 本体销毁），撞不飞的只扣血。
if (global.is_paused) exit;

x += move_speed;
life++;
image_index = (life div 4) mod sprite_get_number(sprite_index);

with (obj_enemy_parent)
{
    if (hp <= 0) continue;
    if (grid_row != other.grid_row) continue;
    if (ds_list_find_index(other.hitted, id) != -1) continue;

    // 命中口径：灰烬卡走 can_hit_ash（dance 也吃）；1 转起「对地下有效」→ 钻地 / 鼹鼠单独放行
    var _ok = can_hit_ash(other.target_type, target_type);
    if (!_ok && other.hit_underground && target_type == "underground") _ok = true;
    if (!_ok) continue;

    if (!precise_bbox_collision(other.id, id)) continue;

    ds_list_add(other.hitted, id);

    // 跨服远征的 BOSS 不参与冲撞（同白羊座）
    if (is_boss && global.map_name == "跨服远征") continue;

    if (crash_immune_enemy(id))
    {
        hp -= other.damage;
        event_user(0);
    }
    else
    {
        var _fx = instance_create_depth(x, y, depth, obj_knock_back_effect);
        _fx.sprite_index  = other.sprite_index;
        _fx.image_index   = other.image_index;
        instance_destroy();
        exit;
    }
}

if (x > end_x) instance_destroy();
