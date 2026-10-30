if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

zodiac_timer++;
if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    // 索敌：0/1转前方3行、2转前方5行内最近的可见陆军，排除地下鼠与未显形鬼鼠
    // 归元马忽略傀儡马（不索敌、不攻击傀儡马代理）
    var gy_list = [];
    for (var gy_i = 0; gy_i < instance_number(obj_enemy_parent); gy_i++) {
        var gy_e = instance_find(obj_enemy_parent,gy_i);
        if (instance_exists(gy_e) && gy_e.hp > 0 && gy_e.object_index != obj_kuileima_decoy) array_push(gy_list,gy_e);
    }
    var gy_rows = shape == 2 ? 2 : 1;
    var t = noone, gy_dist = 2147483647;
    // 索敌：整行，不限卡片左右。第 0~8 列与第 10 列及以后的老鼠都要打，
    // 只按行带（gy_rows）与目标类型筛选；追踪弹自己会转向，不需要方向前置条件。
    for (var gy_i = 0; gy_i < array_length(gy_list); gy_i++) {
        var gy_te = gy_list[gy_i];
        if (abs(gy_te.grid_row-grid_row) > gy_rows
            || gy_te.target_type == "underground" || gy_te.target_type == "invisible") continue;
        var gy_td = point_distance(x,y,gy_te.x,gy_te.y);
        if (gy_td < gy_dist) {gy_dist = gy_td; t = gy_te;}
    }
    if (instance_exists(t)) {
        // 0/1转1枚追踪弹，2转2枚
        var gy_n = shape == 2 ? 2 : 1;
        for (var i = 0; i < gy_n; i++) {
            var b = instance_create_depth(x,y-35-i*12,-2500,obj_zodiac_projectile);
            b.kind = "return";
            b.damage = atk;
            b.base_damage = atk;
            b.shape = shape;
            b.target_id = t;
            b.move_x = lengthdir_x(8,0);
            b.move_y = lengthdir_y(8,0);
            b.image_angle = 0;
            b.sprite_index = spr_guiyuanma_bullet;
            if (shape == 1) b.sprite_index = spr_guiyuanma_bullet_1;
            else if (shape >= 2) b.sprite_index = spr_guiyuanma_bullet_2;
            b.can_dandantu_store = false;
        }
    }
}
