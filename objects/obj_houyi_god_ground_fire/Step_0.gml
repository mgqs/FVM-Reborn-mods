// obj_houyi_god_ground_fire（后羿 · 地火格）Step 事件
// 持续 life 帧（默认 30 = 0.5s）；single_hit 口径：整段每帧都扫格，但每只敌人只烧**一次**。
// 与 obj_fashishe_poison_cell 的差别只有两点：
//   1) 伤害是一次性的（single_hit = true，靠 burned 名单去重），不是每 tick_interval 一跳；
//   2) 真敌人击杀后**不冒灰烬**（灰烬由子弹自己的 ash_kill 分支负责），这里只管扣血。
if (global.is_paused) exit;

t++;

// 帧推进：frame_start~frame_end 铺到整段 life 上
//   anim_loop_frames > 0 → 按那个周期循环（烤肉/法师蛇那种长火）
//   anim_loop_frames = 0 → 单趟播完停在末帧（这里的 0.5s 短火；不能取 t mod life，
//     否则 t == life 那一下会跳回第 1 帧再烧一帧，看起来像火苗闪了一下）
if (life > 1)
{
    var _span  = frame_end - frame_start + 1;
    var _cycle = (anim_loop_frames > 0) ? anim_loop_frames : (life + 1);
    var _tt    = (anim_loop_frames > 0) ? (t mod _cycle) : min(t, _cycle);
    image_index = frame_start + floor(_tt / _cycle * _span);
    if (image_index > frame_end) image_index = frame_end;
}

if (t <= life && variable_global_exists("enemy_by_type"))
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

            // 同一只只吃一次（0.5s 内走进来也算一次；走出去再进来不重复烧）
            if (ds_list_find_index(burned, _e.id) != -1) continue;
            ds_list_add(burned, _e.id);

            // 身上挂 0.5s 着火特效（复用法师蛇/烤肉那套跟随器，贴图按形态自动选）
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
                    // 真敌人：走敌人自己的受伤流程（Other_10）—— 护盾 / 海克斯倍率 /
                    //   测试关统计都在这条路上；死亡也交给它自己，别在这里 instance_destroy
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
if (t > life + 4)
{
    if (ds_exists(burned, ds_type_list)) ds_list_destroy(burned);
    instance_destroy();
}
