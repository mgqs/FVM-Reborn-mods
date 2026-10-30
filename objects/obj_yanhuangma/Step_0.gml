if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

zodiac_timer++;
if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    // 无论场上是否有敌人，都按攻击间隔进入攻击动画。
    state = CARD_STATE.ATTACK;
    image_index = idle_anim+1;
    zodiac_shot_this_anim = false;
}

// 攻击动画推进到第18帧（idle_anim+5）时发射子弹；动画循环回起点后恢复待机
if (state == CARD_STATE.ATTACK) {
    if (!zodiac_shot_this_anim && image_index == idle_anim+5) {
        zodiac_shot_this_anim = true;
        // 四只横向子弹：根据卡片所在行，取其上中缝隙和中下缝隙，左右各一只。
        // 左侧向右、右侧向左飞行；每只覆盖相邻两行。
        var yh_spr = spr_yanhuangma_bullet;
        if (shape == 1) yh_spr = spr_yanhuangma_bullet_1;
        else if (shape >= 2) yh_spr = spr_yanhuangma_bullet_2;
        // 发射起点用战斗域边界：右端要退到第 10 列右沿之外，否则站在场外那一列的老鼠永远打不到
        var area_left = combat_left_x(), area_right = combat_right_x();
        var upper_gap = clamp(grid_row,1,global.grid_rows-1);
        var lower_gap = clamp(grid_row+1,1,global.grid_rows-1);
        var yh_gaps = [upper_gap,upper_gap,lower_gap,lower_gap];
        var yh_side_x = [area_left-20,area_right+20,area_left-20,area_right+20];
        var yh_dirs = [0,180,0,180];
        for (var yh_i = 0; yh_i < 4; yh_i++) {
            var yb = instance_create_depth(yh_side_x[yh_i],global.grid_offset_y+(yh_gaps[yh_i]-0.25)*global.grid_cell_size_y,-2500,obj_zodiac_projectile);
            yb.kind = "phoenix";
            yb.damage = atk;
            yb.base_damage = atk;
            yb.shape = shape;
            yb.target_id = noone;
            yb.move_x = lengthdir_x(8,yh_dirs[yh_i]);
            yb.move_y = lengthdir_y(8,yh_dirs[yh_i]);
            yb.image_angle = yh_dirs[yh_i];
            yb.sprite_index = yh_spr;
            yb.can_dandantu_store = false;
            yb.cover_a = yh_gaps[yh_i]-1;
            yb.cover_b = yh_gaps[yh_i];
            if (yh_dirs[yh_i] == 180) {
                yb.image_angle = 0;
                yb.image_xscale = -1;
            }
        }
    }
    if (zodiac_shot_this_anim && image_index == idle_anim+1) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
if (shape >= 1) {
    zodiac_vertical_timer++;
    if (zodiac_vertical_timer >= 300) {
        var count = 0, strongest = noone;
        for (var i = 0; i < instance_number(obj_yanhuangma); i++) {
            var p = instance_find(obj_yanhuangma,i);
            if (!instance_exists(p) || p.hp <= 0) continue;
            count++;
            if (p.shape >= 1 && (!instance_exists(strongest) || p.atk > strongest.atk
                || (p.atk == strongest.atk && p.id < strongest.id))) strongest = p;
        }
        if (count >= 7 && strongest == id) {
            // 一转：最右两列（第8/9列）各召唤1发竖向子弹，从上向下飞行；第8列受击2次，第9列1次。
            var yh_spr = spr_yanhuangma_bullet;
            if (shape == 1) yh_spr = spr_yanhuangma_bullet_1;
            else if (shape >= 2) yh_spr = spr_yanhuangma_bullet_2;
            var grid_left = global.grid_offset_x;
            var vx = [grid_left+7.5*global.grid_cell_size_x,grid_left+8.5*global.grid_cell_size_x];
            for (var vi = 0; vi < 2; vi++) {
                var vb = instance_create_depth(vx[vi],global.grid_offset_y-0.25*global.grid_cell_size_y,-2500,obj_zodiac_projectile);
                vb.kind = "phoenix";
                vb.damage = atk;
                vb.base_damage = atk;
                vb.shape = shape;
                vb.target_id = noone;
                // GameMaker 270 degrees points downward; traverse the full field from top row to bottom row.
                vb.move_x = lengthdir_x(8,270);
                vb.move_y = lengthdir_y(8,270);
                vb.image_angle = 270;
                vb.sprite_index = yh_spr;
                vb.can_dandantu_store = false;
                vb.vertical = true;
                vb.cover_a = 7+vi;
                vb.cover_b = 7+vi;
            }
            zodiac_vertical_timer = 0;
        }
        // 未满足7只时保留计时，满足条件后立即由最高攻击力卡片召唤。
        if (count < 7) zodiac_vertical_timer = 300;
    }
}
