if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

zodiac_timer++;
if (zodiac_timer >= cycle) {
    zodiac_timer = 0;
    // 与里格一致：前方没有可攻击老鼠时不进入攻击动画，也不生成星弹。
    var has_target = false;
    if (variable_global_exists("enemy_sx") && variable_global_exists("enemy_sx_n")) {
        var _sx = global.enemy_sx;
        var _n = min(global.enemy_sx_n,array_length(_sx));
        var _start = 0;
        if (variable_global_exists("enemy_sx_l")) {
            var _lo = 0;
            var _hi = _n - 1;
            var _cut = x - global.grid_cell_size_x;
            while (_lo < _hi) {
                var _mid = floor((_lo + _hi) / 2);
                if (global.enemy_sx_l[_mid] < _cut) _lo = _mid + 1;
                else _hi = _mid;
            }
            _start = _lo;
        }
        for (var _i = _start; _i < _n; _i++) {
            var _e = _sx[_i];
            if (!instance_exists(_e) || _e.hp <= 0) continue;
            if (_e.grid_col > grid_col && can_target_on(target_type,_e.target_type)) {has_target = true; break;}
        }
    }
    if (has_target) {
        state = CARD_STATE.ATTACK;
        image_index = idle_anim + 1;
        zodiac_shot_this_anim = false;
    } else {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
if (state == CARD_STATE.ATTACK) {
    // 动画第18帧执行攻击动作：五个方向各发一发；转数只提高伤害倍率，不增加子弹实例数量。
    if (!zodiac_shot_this_anim && image_index == 18) {
        zodiac_shot_this_anim = true;
        var shot_shape = clamp(round(shape),0,2);
        if (sprite_index == asset_get_index("spr_starrabbit_2")) shot_shape = max(shot_shape,2);
        else if (sprite_index == asset_get_index("spr_starrabbit_1")) shot_shape = max(shot_shape,1);
        var angles = [0,22.5,-22.5,45,-45];
        var damage_multiplier = shot_shape + 1;
        var sr_spr = spr_starrabbit_bullet;
        if (shot_shape == 1) sr_spr = spr_starrabbit_bullet_1;
        else if (shot_shape >= 2) sr_spr = spr_starrabbit_bullet_2;
        var sr_dmg = atk*damage_multiplier;
        for (var i = 0; i < array_length(angles); i++) {
            var b = instance_create_depth(x,y-30,-2500,obj_zodiac_projectile);
            b.kind = "star";
            b.damage = sr_dmg;
            b.base_damage = sr_dmg;
            b.shape = shot_shape;
            b.target_id = noone;
            b.move_x = lengthdir_x(8,angles[i]);
            b.move_y = lengthdir_y(8,angles[i]);
            b.image_angle = angles[i];
            b.sprite_index = sr_spr;
            b.can_dandantu_store = false;
            b.damage_type = "pierce";
            b.center_row = grid_row;
        }
    }
    if (zodiac_shot_this_anim && zodiac_timer > 0 && image_index == idle_anim + 1) {
        state = CARD_STATE.IDLE;
        image_index = 0;
        zodiac_shot_this_anim = false;
    }
}
