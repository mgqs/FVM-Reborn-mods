// obj_galaxy_horse_bullet Step 事件
if (global.is_paused)
    exit;

// 延迟段（二转 3 发之间的错帧）
if (gh_delay > 0)
{
    gh_delay--;
    exit;
}

image_alpha = 1;
image_index += gh_frame_speed;

// 进入炸点帧那一瞬间结算一次
if (!gh_done && image_index >= gh_impact_idx)
{
    gh_done = true;

    var _cx    = gh_col;     // 落点列（与敌人 grid_col 同一坐标系）
    var _cy    = gh_row;     // 落点行 = 出弹时锁定目标所在行（见 Other_11）
    var _cols  = gh_splash_cols;
    var _rows  = gh_splash_rows;
    var _dmg   = gh_damage;
    var _ratio = gh_splash_ratio;
    var _stun  = gh_stun;

    // ── 索敌目标 = 出弹时锁定的那只（只有它吃全额）──
    // 旧实现在这里**无条件**按「本行离落点最近的一只」重算，而落点又是兜底空地，
    // 于是全额伤害糊到一只无辜老鼠身上、真正的目标只吃 50% —— 这就是
    // 「陨石砸下去，锁的那只没死、旁边那只死了」的来源。
    // 现在优先用 gh_target；它中途死了/被击退换行了，才退回「同格附近最近的一只」。
    var _primary = noone;
    if (instance_exists(gh_target) && gh_target.hp > 0
        && object_is_ancestor(gh_target.object_index, obj_enemy_parent))
    {
        // object_is_ancestor 挡一道：gh_target 若在落地这 0.4 秒里被销毁，
        // 它的 id 可能已经被别的新实例复用，只判 instance_exists 会把全额糊给陌生实例。
        _primary = gh_target;
    }
    else
    {
        var _best = 2;   // 只接受 ±1 格内的目标（覆盖 0.4 秒落地期间的正常位移）
        with (obj_enemy_parent)
        {
            if (hp > 0
                && variable_instance_exists(id, "target_type")
                && variable_instance_exists(id, "grid_row")
                // 非主流鼠啃食时 target_type 会从 "dance" 变回 "normal"，只靠 gh_hittable 拦不住
                // —— 卡面口径是「无法攻击非主流」，所以这里按身份再排一次（见 is_non_mainstream）。
                && !is_non_mainstream(id)
                && grid_row == _cy
                && array_get_index(other.gh_hittable, target_type) != -1)
            {
                var _d = abs(grid_col - _cx);
                if (_d < _best)
                {
                    _best = _d;
                    _primary = id;
                }
            }
        }
    }

    with (obj_enemy_parent)
    {
        // 守 3 个字段：obj_enemy_parent 的 297 个直接子对象里有缺 target_type / grid_* 的，
        // GML 读未定义实例变量是硬崩，不是静默 false。
        if (hp > 0
            && variable_instance_exists(id, "target_type")
            && variable_instance_exists(id, "grid_row")
            && variable_instance_exists(id, "grid_col")
            // 卡面「无法攻击非主流」：非主流鼠啃食时 target_type 变回 normal，白名单拦不住，
            // 这里按身份再排一次（见 is_non_mainstream）。
            && !is_non_mainstream(id)
            && (id == _primary || (abs(grid_row - _cy) <= _rows
                && abs(grid_col - _cx) <= _cols))
            && array_get_index(other.gh_hittable, target_type) != -1)
        {
            // ── 伤害口径（官方 A116「均秒杀不防爆，击杀灰烬」）──────────────────
            //   索敌目标 = 攻击力全额；溅射目标 = 攻击力 × gh_splash_ratio。
            //   非防爆（!immune_to_ash）且非 BOSS → 直接按当前 hp 结算，一击必杀；
            //   防爆鼠 / BOSS 只吃上面那笔数值伤害（不秒杀）。
            //   BOSS 判定抄 obj_hufa_god_bullet/Step_0.gml:93-100 的双通道：
            //   先看实例字段 is_boss，再拿 mouse_id 去 global.boss_list 兜一道
            //   （BOSS 对象里 is_boss 偶尔没写，只有注册表能认出来）。
            var _is_boss = variable_instance_exists(id, "is_boss") && is_boss;
            if (!_is_boss && variable_global_exists("boss_list")
                && ds_exists(global.boss_list, ds_type_map)
                && variable_instance_exists(id, "mouse_id")
                && ds_map_exists(global.boss_list, mouse_id))
            {
                _is_boss = true;
            }
            var _immune = variable_instance_exists(id, "immune_to_ash") && immune_to_ash;

            var _deal = (id == _primary) ? _dmg : _dmg * _ratio;
            if (!_is_boss && !_immune)
                _deal = max(_deal, hp);   // 秒杀：至少按当前血量结算

            damage_amount = _deal;
            damage_type   = "ash";
            event_user(0);

            // 一转起：眩晕 2 秒（不查 immune_to_ash —— 官方「眩晕防爆鼠」）
            if (hp > 0 && _stun > 0 && stun_timer < _stun)
                stun_timer = _stun;

            // 击杀一律出灰烬。⚠ 这里**不能** instance_destroy()：那会绕过
            // obj_enemy_parent/Step_0.gml:427 的死亡结算（hex_batch2_on_enemy_death /
            // hex_on_kill / hex_try_drop），海克斯的击杀奖励与掉卡全部丢失（MISTAKES B18）。
            // 置 ash_death 后由敌人自己在同一帧走完结算再销毁。
            if (hp <= 0)
            {
                if (special_ash)
                {
                    var _ash = instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                    _ash.special_ash = true;
                    _ash.sprite_index = sprite_index;
                    _ash.image_index = image_index;
                }
                else
                {
                    instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
                }
                frozen_timer = 0;
                ice_timer    = 0;
                scare_timer  = 0;
                ash_death    = true;
                image_alpha  = 0;
            }
        }
    }

    audio_play_sound(snd_coke_bomb_explode, 0, 0);
    if (global.screen_shake)
        Camera_Shock(4, 14);
}

if (image_index >= sprite_get_number(sprite_index))
    instance_destroy();
