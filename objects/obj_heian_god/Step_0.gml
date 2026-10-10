// ========== 子对象 Step 事件 ==========

if global.is_paused {
    image_speed = 0;
    exit;
}

if !awakened && sprite_index == awake_sprite {
    image_speed = 0.8;
}

// ========== 觉醒动画处理 ==========
if !awakened {
    // 开始播放觉醒动画
    if !awakening_started {
        awakening_started = true;

        // 只在第一次时调用父对象，获取初始化数据
        event_inherited();

        // 然后覆盖为自己的动画
        sprite_index = awake_sprite;
        image_speed = 0.8;
        image_index = 0;
    }

    // 检查动画是否播放完毕
    if sprite_index == awake_sprite {
        if image_index >= image_number - 1 {
            awakened = true;
            sprite_index = idle_sprite;
            image_speed = 0.8;
            image_index = 0;

            state = CARD_STATE.IDLE;
        }
    }
}

// ========== 觉醒完成后 ==========
else {
    // 确保待机动画
    if sprite_index != idle_sprite {
        sprite_index = idle_sprite;
    }
    image_speed = 0.8;

    // 计时器消失效果（觉醒后才开始计时）
    destroy_timer++;
    if destroy_timer > max_time {
        image_alpha -= 0.1;
        if image_alpha <= 0 {
            instance_destroy();
            exit;
        }
    }

    // 攻击间隔计时器
    attack_interval_timer++;
    if (attack_interval_timer >= 30) {
        attack_interval_timer = 0;

        // 计算范围
        var range_cols, range_rows;
        if (shape == 0 || shape == 1) {
            range_cols = 2;  // 5列
            range_rows = 2;  // 5行
        } else {
            range_cols = 2;  // 5列
            range_rows = 3;  // 7行
        }

        // 造成伤害
        with (obj_enemy_parent) {
            var col_diff = abs(grid_col - other.grid_col);
            var row_diff = abs(grid_row - other.grid_row);

            if (hp > 0 && col_diff <= range_cols && row_diff <= range_rows) {
                // 计算伤害（卡片 shape = 3 时给敌人独立计数）
                var final_damage = other.atk;
      if (other.shape == 3) {
            final_damage = other.atk * attack_multiplier;
            attack_multiplier++;
            }

                damage_amount = final_damage;
                damage_type = "throw";
                event_user(0);

                // 检查死亡
                if hp <= 0 {
                    // shape >= 3 时只播放灰烬特效
                    if other.shape >= 3 {
                        var inst = instance_create_depth(x, y-20, depth, obj_mouse_ash_death_4);
                        inst.special_ash = true;
                        instance_destroy();
                    }
                }
            }
        }
    }
}

if is_frozen {
    exit;
}
