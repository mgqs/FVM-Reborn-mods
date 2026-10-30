if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

zodiac_timer++;

// 出风后播放一次攻击动画（12~24 帧），播完自动回待机
if (yf_atk_timer > 0) {
    yf_atk_timer--;
    if (yf_atk_timer <= 0) {
        yf_atk_timer = 0;
        state = CARD_STATE.IDLE;
    }
}

if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    // 场上存在排风扇、9周年幸运草扇或旋风牛时改为3行大风，可受宴会女神增幅
    var big = false;
    for (var i = 0; i < instance_number(obj_card_parent); i++) {
        var p = instance_find(obj_card_parent,i);
        if (!instance_exists(p) || p.hp <= 0) continue;
        if (p.plant_id == "ventilation_fan" || p.plant_id == "xuanfengniu") {big = true; break;}
        var yf_pd = get_plant_shape_data(p.plant_id,0);
        if (yf_pd != undefined && string_pos("9周年幸运草扇",yf_pd[? "name"]) > 0) {big = true; break;}
    }
    // 索敌：前方指定行数内最近的可见陆军/空军，排除地下鼠与未显形鬼鼠
    var yf_list = [];
    for (var yf_i = 0; yf_i < instance_number(obj_enemy_parent); yf_i++) {
        var yf_e = instance_find(obj_enemy_parent,yf_i);
        if (instance_exists(yf_e) && yf_e.hp > 0) array_push(yf_list,yf_e);
    }
    for (var yf_i = 0; yf_i < instance_number(obj_kuileima_decoy); yf_i++) {
        var yf_d = instance_find(obj_kuileima_decoy,yf_i);
        if (instance_exists(yf_d) && yf_d.hp > 0 && !array_contains(yf_list,yf_d)) array_push(yf_list,yf_d);
    }
    var yf_rows = big ? 1 : 0;
    var t = noone, yf_dist = 2147483647;
    // 索敌：整行，不限卡片左右。第 0~8 列与第 10 列及以后的老鼠都要打，
    // 只按行带（yf_rows）与目标类型筛选；出风方向随后按目标在哪一侧决定。
    for (var yf_i = 0; yf_i < array_length(yf_list); yf_i++) {
        var yf_te = yf_list[yf_i];
        if (abs(yf_te.grid_row-grid_row) > yf_rows
            || yf_te.target_type == "underground" || yf_te.target_type == "invisible") continue;
        var yf_td = point_distance(x,y,yf_te.x,yf_te.y);
        if (yf_td < yf_dist) {yf_dist = yf_td; t = yf_te;}
    }
    if (instance_exists(t)) {
        var spr = spr_yufengma_bullet;
        if (shape == 1) spr = spr_yufengma_bullet_1;
        else if (shape >= 2) spr = spr_yufengma_bullet_2;
        if (big) {
            spr = spr_yufengma_bullet_big;
            if (shape == 1) spr = spr_yufengma_bullet_big_1;
            else if (shape >= 2) spr = spr_yufengma_bullet_big_2;
        }
        var b = instance_create_depth(x,y-30,-2500,obj_zodiac_projectile);
        b.kind = "wind";
        b.damage = atk;
        b.base_damage = atk;
        b.shape = shape;
        b.target_id = noone;
        // 龙卷风横向贯穿本行，朝目标所在的一侧吹：目标在左侧时贴图水平翻转。
        // 原来固定向右，导致卡片放在中间/右侧时索敌到左侧老鼠却永远空放。
        var _wind_dir = (t.x < x) ? -1 : 1;
        b.move_x = _wind_dir * 8;
        b.move_y = 0;
        b.image_angle = 0;
        if (_wind_dir < 0) b.image_xscale = -1;
        b.sprite_index = spr;
        b.can_dandantu_store = false;
        b.rows = big ? 1 : 0;
        b.center_row = grid_row;
        if (big && spr >= 0) {
            // 有风扇时大风弹：shape0/1/2 分别使用 bullet_big/_1/_2，动画纵向拉伸至3行高度并以卡片行中心对称覆盖（伤害同为这3行）
            b.image_yscale = 3*global.grid_cell_size_y/sprite_get_height(spr);
            b.y = y - 1.5*global.grid_cell_size_y + sprite_get_yoffset(spr)*b.image_yscale;
        }
        // 出风即播放攻击动画
        state = CARD_STATE.ATTACK;
        yf_atk_timer = attack_anim * flash_speed;
    }
}
