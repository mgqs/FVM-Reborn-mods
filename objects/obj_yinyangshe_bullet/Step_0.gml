// obj_yinyangshe_bullet Step 事件
// 移动 → 逐只判定命中（同行 + 同列 + 类型白名单）→ 附毒 → 非穿透弹自毁。
if (global.is_paused)
    exit;

x += move_speed;
yy_life++;

// ── 过火外观 ──────────────────────────────────────────────────────────
//   🔴 父对象 bullet_hazard_fire 的「普通火源」分支只改倍率 / 尺寸 / 播个音效，
//      **不换贴图**；换成通用火弹是每颗子弹在自己的 Step 里做的事
//      （bbq / 法士蛇 / 玉米子弹……全是这个写法）。不写这段就是
//      「过火有伤害、有放大，但看起来还是原来那颗弹」。
//   融盆二转会把子弹改成冰弹（brazier_list 插哨兵 -9999，贴图归 obj_ronghehuopen_ice_ctrl 接管），
//      这里必须让路，否则每帧被改回火球。
var _dir = (move_speed >= 0) ? 1 : -1;
var _sc  = 1.6;
var _is_ice_bullet = (variable_instance_exists(id, "brazier_list")
                   && ds_list_find_index(brazier_list, -9999) != -1);
if (burnt > 0 && !_is_ice_bullet)
{
    sprite_index = spr_fire_bullet;      // 41×14，尖尾在左、圆头朝右 = 默认朝右
    image_speed  = 0;                    // 帧自己推，别让引擎再叠一层
    image_index  = (yy_life div 4) mod sprite_get_number(spr_fire_bullet);   // 4 帧火苗
    image_blend  = c_white;
    _sc = 1.8;                           // 与其它普通子弹过火一致
}

// 左右镜像跟随飞行方向（被布丁弹回后朝左飞，子弹也跟着翻）
var _want_sx = _sc * _dir;
visual_scale_x = _want_sx;
visual_scale_y = _sc;
// 父对象 BeginStep 每帧把 image_scale 夹回 1，而 bbox 只认 image_scale —— 每帧重设一次
image_xscale = _want_sx;
image_yscale = _sc;

yy_col_now = floor((x - global.grid_offset_x) / global.grid_cell_size_x);

with (obj_enemy_parent)
{
    // 少数自制敌人没写这几个字段，直接读是硬崩，先守
    if (!variable_instance_exists(id, "hp")
        || !variable_instance_exists(id, "grid_col")
        || !variable_instance_exists(id, "grid_row")
        || !variable_instance_exists(id, "target_type"))
        continue;

    if (hp <= 0) continue;
    if (grid_row != other.row) continue;
    if (grid_col != other.yy_col_now) continue;
    if (ds_list_find_index(other.hitted, id) != -1) continue;
    if (!can_hit(other.target_type, target_type)) continue;

    ds_list_add(other.hitted, id);

    damage_amount = other.damage;
    damage_type   = "normal";
    event_user(0);

    // 附毒：毒伤 = 攻击力 × 火盆倍率 × 3 / 3 / 4.5，分 3 次跳完
    //   🔴 不看 hp > 0：这张卡攻击力低（10~145），命中常常当场打死，
    //      写成「活着才上毒」的话毒几乎永远不生效。
    if (other.yy_poison)
    {
        var _hz = instance_create_depth(0, 0, other.depth - 30, other.yy_poison_obj);
        _hz.yy_host       = id;
        _hz.yy_total      = round(other.damage * max(1, other.fire_mult) * other.yy_poison_mult);
        _hz.yy_tick_gap   = 20;
        _hz.yy_ticks      = 3;
        _hz.yy_timer      = 0;
        _hz.x = x;
        _hz.y = y;
    }

    audio_play_sound(hit_sound, 0, 0);

    // 非穿透弹：这一发到此为止（同格多只时只结算这一只）
    if (!other.yy_pierce)
    {
        other.yy_stop = true;
        break;
    }
}

if (yy_stop)
{
    instance_destroy();
    exit;
}

// 出界：向右飞出右沿 / 被弹回后向左飞出左沿
if (move_speed >= 0)
{
    if (x > get_world_position_from_grid(end_col, row).x)
        instance_destroy();
}
else if (x < global.grid_offset_x - global.grid_cell_size_x)
{
    instance_destroy();
}
