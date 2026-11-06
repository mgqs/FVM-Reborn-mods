// obj_tunshilong_boom（吞噬龙 · 一转起死亡爆炸）Step 事件
// ① 播爆炸段 boom_first → boom_last（每 flash_speed 帧换一张）
// ② 播到「炸开」那一帧才结算一次 3×3 灰烬（非防爆鼠秒杀出灰烬，防爆鼠 / BOSS 只吃 900）
//    表口径（基本信息.xlsx）：一转死亡造成 3*3 灰烬伤害
if (global.is_paused) exit;

t++;
image_index = boom_first + floor(t / flash_speed);

if (!hit_done && image_index >= hit_index){
    hit_done = true;

    with (obj_enemy_parent){
        if (hp <= 0) continue;
        if (abs(grid_row - other.grid_row) > 1) continue;      // 3×3 = 上下各 1 格
        if (abs(grid_col - other.grid_col) > 1) continue;

        if (is_boss || (immune_to_ash && hp > 900)){
            // 防爆 / BOSS：只吃 900，绝不进秒杀分支
            damage_amount = 900;
            damage_type = "normal";
            event_user(0);
        }
        else{
            // 普通鼠：秒杀，出灰烬
            damage_amount = 0;
            instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
            instance_destroy();
        }
    }
}

if (image_index > boom_last){
    instance_destroy();
}
