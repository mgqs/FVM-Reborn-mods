// obj_houyi_god_ground_fire（后羿 · 地火格）Step 事件
// 每 tick_interval 帧结算一跳（第 1 帧就结算第一跳），格内每只敌人每跳都吃 damage；
// 多片地火叠在同一格 = 各自结算 = 「可叠加层数」，和法师蛇毒雾同口径。
// 真敌人击杀后**不冒灰烬**（灰烬由子弹自己的 ash_kill 分支负责），这里只管扣血。
if (global.is_paused) exit;

t++;

// 帧推进：frame_start~frame_end 铺到 anim_loop_frames 帧上一轮循环
if (life > 1)
{
    var _span  = frame_end - frame_start + 1;
    var _cycle = (anim_loop_frames > 0) ? anim_loop_frames : life;
    image_index = frame_start + floor((t mod _cycle) / _cycle * _span);
    if (image_index > frame_end) image_index = frame_end;
}

if (t <= life && ((t - 1) mod tick_interval) == 0 && variable_global_exists("enemy_by_type"))
{
    for (var _t = 0; _t < array_length(hittable_types); _t++)
    {
        var _key = hittable_types[_t];
        if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
        var _list = global.enemy_by_type[$ _key];
        for (var _i = 0; _i < array_length(_list); _i++)
        {
            var _e = _list[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (is_digging_dijing(_e)) continue;                  // 龙渊地精钻地时不烧

            // 只烧「就是这一格」：行严格相等，列在本格 ~ 本格+extra_col_right
            if (_e.grid_row != grid_row) continue;
            if (_e.grid_col < grid_col || _e.grid_col > grid_col + extra_col_right) continue;

            // 身上挂着火特效（跟着这只鼠走，life_off 帧后自己消失）
            var _fx_spr = mouse_fx_spr;
            if (_fx_spr == -1)
            {
                _fx_spr = spr_houyi_god_fire;
                if (shape == 1)      _fx_spr = spr_houyi_god_fire_1;
                else if (shape == 2) _fx_spr = spr_houyi_god_fire_2;
                else if (shape == 3) _fx_spr = spr_houyi_god_fire_3;
            }
            var _fx = instance_create_depth(_e.x, _e.y, _e.depth - 1, obj_bbq_mouse_burn);
            _fx.fx_spr       = _fx_spr;
            _fx.target       = _e;
            _fx.life         = mouse_fx_life;
            _fx.life_total   = mouse_fx_life;
            _fx.x_off        = mouse_fx_x_off;
            _fx.y_off        = mouse_fx_y_off;
            _fx.image_xscale = mouse_fx_scale;
            _fx.image_yscale = mouse_fx_scale;

            with (_e)
            {
                if (object_index == obj_enemy_parent || object_is_ancestor(object_index, obj_enemy_parent))
                {
                    // 真敌人：只结算伤害，死亡交给 obj_enemy_parent 自己的流程
                    damage_amount = other.damage;
                    damage_type   = other.damage_type;
                    event_user(0);
                }
                else
                {
                    // 障碍物没有死亡流程，血量归零就自己销毁
                    hp -= other.damage;
                    if (hp <= 0) instance_destroy();
                }
            }
        }
    }
}

// 生命结束后再留 4 帧收尾（末帧火苗散掉）
if (t > life + 4) instance_destroy();
