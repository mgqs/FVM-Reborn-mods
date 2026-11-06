if (global.is_paused) exit;

// 火苗贴图循环
image_index = (ticks * 3 + tick_timer div 3) mod sprite_get_number(sprite_index);

tick_timer++;
if (tick_timer >= tick_gap){
    tick_timer = 0;
    ticks++;

    // 2026-11-06 用户口径：**每跳伤害 = 攻击力本身**（单次伤害，不是「总计 ÷ 跳数」）
    //   原来按总伤分摊，10 跳每跳只有 atk/10，实际只打了 1 发攻击力
    var _per = damage;

    var _cross = (shape < 2);
    with (obj_enemy_parent){
        if (hp <= 0) continue;
        var _dr = grid_row - other.grid_row;
        var _dc = grid_col - other.grid_col;
        var _in = false;
        if (abs(_dr) <= 1 && abs(_dc) <= 1){
            if (_cross){
                _in = (abs(_dr) + abs(_dc) <= 1);
            }
            else{
                _in = true;
            }
        }
        if (_in){
            damage_amount = _per;
            damage_type = "ash";
            event_user(0);
        }
    }
}

if (ticks >= total_ticks){
    image_alpha -= 0.08;
    if (image_alpha <= 0) instance_destroy();
}
