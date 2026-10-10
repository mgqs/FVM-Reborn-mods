if global.is_paused{
	exit
}

// 击中后：播放爆炸动画（5-15帧）
if (hit_enemy) {
    image_index += 0.3;

    // 碎裂动画播完（走过 idx 15）即销毁
    if (image_index >= 16) {
        instance_destroy();
        exit;
    }

    // 刚进入碎裂首帧（idx 5）时炸开，造成溅射伤害
    if (!has_splashed && floor(image_index) >= 5) {
        has_splashed = true;

        var _x = x;
        var _y = y;
        if instance_exists(hitted_enemy) {
            _x = hitted_enemy.x;
            _y = hitted_enemy.y;
        }

        var _range = 200;

        with (obj_enemy_parent) {
            if (hp > 0 && point_distance(x, y, _x, _y) < _range && grid_row <= other.row+1 && grid_row >= other.row-1 && id != other.hitted_enemy and can_hit(other.target_type, target_type)) {

                // 溅射伤害（三档恒定 35%，见 obj_ronghedan_god/Create_0）
                damage_amount = other.damage * other.splash_ratio;
                damage_type = other.damage_type;
                event_user(0);

                // 溅射附带定身效果（概率减半）
                var _chance = other.stun_chance * 0.5;
                var _duration = other.stun_duration;
                if (random(100) < _chance) {
                    if (stun_timer < _duration) {
                        stun_timer = _duration;
                    }
                }
            }
        }

        // 深度融合（1 转起）：命中格 3×3 范围附加 1 次毒气伤害
        if (shape >= 1) {
            var grid_pos = get_grid_position_from_world(_x, _y);
            var inst = instance_create_depth(grid_pos.x, grid_pos.y, depth, obj_ronghedan_god_poison_effect);
            inst.damage = poison_damage;
            inst.grid_row = grid_pos.row;
        }
    }

    exit;
}

// ========== 飞行中 ==========
x += move_speed
y -= cvspeed
cvspeed -= cgravity
image_angle -= 5

// 飞行动画：只播完整鸡蛋帧（idx 0-4）—— 碎片帧（idx 5-15）留给命中/落地时播
image_index += 0.2;
if (image_index >= 4.99) {
    image_index = 0;
}
if (image_index < 0) {
    image_index = 0;
}

// 碰撞检测
hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
    hit_tick = 0;
    if (bullet_enemy_reachable(id)) {
        if (variable_global_exists("enemy_by_type"))
        {
            var _hit = false;
            var _hit_enemy_id = noone;
            // This bullet moves continuously; invalidate the spatial query
            // cache so candidates are rebuilt at its current position.
            _sap_gen = -1;
            for (var _t = 0; _t < array_length(hittable_types); _t++)
            {
                var _key = hittable_types[_t];
                if (!variable_struct_exists(global.enemy_by_type, _key)) continue;
                var _list = bullet_sap_type_list(id, _key);
                for (var _i = 0; _i < array_length(_list); _i++)
                {
                    var _e = _list[_i];
                    if (!instance_exists(_e)) continue;
                    if (_e.hp > 0 && row == _e.grid_row
            && precise_bbox_collision(id, _e))
                    {
                        // 对命中敌人造成伤害
                        with (_e)
                        {
                            damage_amount = other.damage
                            damage_type = other.damage_type
                            event_user(0)
                            // 定身效果（按星级查表，见 obj_ronghedan_god/Create_0）
                            var _chance = other.stun_chance;
                            var _duration = other.stun_duration;
                            if (random(100) < _chance) {
                                if (stun_timer < _duration) {
                                    stun_timer = _duration;
                                }
                            }
                        }
                        _hit = true;
                        _hit_enemy_id = _e.id;
                        break;
                    }
                }
                if (_hit) break;
            }

            if (_hit) {
                hit_enemy = true;
                hitted_enemy = _hit_enemy_id;
                image_index = 5;      // 碎裂首帧
                has_splashed = false;
                audio_play_sound(snd_egg_bullet, 0, 0);
                exit;
            }
        }
    }
}

// 超出边界销毁
if x > 2200 or y > 1200 or x < -200 or y < -200{
    instance_destroy()
    exit
}

// 落地（没砸到敌人）：直接消失 —— 不碎裂、不溅射、不生成毒雾
//   只有真正砸到敌人的子弹才会走上面的碎裂分支（溅射 / 毒雾都在那里）
if (!hit_enemy && y >= thrower_y){
    instance_destroy();
    exit;
}

// 水果挞增幅
if !atk_modified{
    with obj_card_parent{
        if plant_id == "fruit_tart"{
            if grid_row == other.row && ((shape <= 1 && x >= other.x) || shape >= 2){
                other.damage *= atk
                other.atk_modified = true
            }
        }
    }
}
