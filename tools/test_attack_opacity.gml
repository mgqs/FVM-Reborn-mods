function opacity_assert(_ok, _message) {
    if (!_ok) {
        show_debug_message("ATTACK_OPACITY_FAIL: " + _message);
        game_end();
    }
}

function opacity_pixel(_inst, _method, _expected, _green = false) {
    surface_set_target(probe_surface);
    draw_clear_alpha(c_black, 1);
    draw_set_alpha(0.8);
    with (_inst) {
        switch (_method) {
            case 0: draw_self(); break;
            case 1: draw_sprite(sprite_index, 0, 0, 0); break;
            case 2: draw_sprite_ext(sprite_index, 0, 0, 0, 1, 1, 0, c_white, 0.8); break;
            case 3: draw_sprite_part(sprite_index, 0, 0, 0, 8, 8, 0, 0); break;
            case 4: draw_sprite_part_ext(sprite_index, 0, 0, 0, 8, 8, 0, 0, 1, 1, c_white, 0.8); break;
        }
    }
    opacity_assert(abs(draw_get_alpha() - 0.8) < 0.001, "draw alpha restored");
    surface_reset_target();
    var _pixel = surface_getpixel(probe_surface, 4, 4);
    var _channel = _green ? color_get_green(_pixel) : color_get_red(_pixel);
    opacity_assert(abs(_channel / 255 - _expected) < 0.025,
        "pixel method=" + string(_method) + " expected=" + string(_expected) + " actual=" + string(_channel / 255));
    opacity_assert(abs(_inst.image_alpha - 0.8) < 0.001 && _inst.damage == 42, "gameplay/fade state retained");
    if (_green) opacity_assert(color_get_red(_pixel) < 4, "replacement animation selected");
}

function opacity_probe_draw() {
    if (probe_done == 2) return;
    if (probe_done == 0) {
    probe_done = 1;
    probe_surface = surface_create(room_width, room_height);
    surface_set_target(probe_surface);
    draw_clear_alpha(c_white, 1);
    probe_sprite = sprite_create_from_surface(probe_surface, 0, 0, 8, 8, false, false, 0, 0);
    draw_clear_alpha(c_lime, 1);
    global.probe_replacement = sprite_create_from_surface(probe_surface, 0, 0, 8, 8, false, false, 0, 0);
    surface_reset_target();
    var _bullet = id;
    _bullet.sprite_index = probe_sprite;
    _bullet.image_alpha = 0.8;
    _bullet.image_speed = 0;
    _bullet.damage = 42;
    probe_bullet = _bullet;
    return; // Let the Runner refresh its native draw_self sprite cache.
    }
    probe_done = 2;
    var _bullet = probe_bullet;

    for (var _anim = 0; _anim < 2; _anim++) {
        global.external_animation_active = (_anim == 1);
        var _values = [1, 0.5, 0, 1];
        for (var _v = 0; _v < array_length(_values); _v++) {
            global.friendly_attack_opacity = _values[_v];
            for (var _method = 0; _method < 5; _method++) opacity_pixel(_bullet, _method, 0.8 * _values[_v], _anim == 1);
        }
    }
    global.external_animation_active = false;
    global.friendly_attack_opacity = 0;
    with (_bullet) instance_change(obj_xiaolongbao_bullet, false);
    opacity_pixel(_bullet, 2, 0);
    // Same instance ID changes type, as it does in the real object pool.
    with (_bullet) instance_change(obj_engineer_bullet, false);
    opacity_pixel(_bullet, 0, 0.8);
    with (_bullet) instance_change(obj_card_parent, false);
    opacity_pixel(_bullet, 0, 0.8);
    with (_bullet) instance_change(obj_player_character, false);
    opacity_pixel(_bullet, 0, 0.8);
    with (_bullet) instance_change(obj_light_atk_effect, false);
    opacity_pixel(_bullet, 0, 0);

    var _card = instance_create_depth(0, 0, 0, obj_card_parent);
    var _enemy = instance_create_depth(0, 0, 0, obj_engineer_bullet);
    var _fx = noone;
    with (_card) _fx = instance_create_depth(0, 0, 0, obj_coke_bomb_explode);
    opacity_assert(_fx.friendly_attack_owned, "friendly shared explosion tagged");
    var _pooled_id = _fx;
    with (_fx) instance_destroy();
    with (_enemy) _fx = instance_create_depth(0, 0, 0, obj_coke_bomb_explode);
    opacity_assert(_fx == _pooled_id && !_fx.friendly_attack_owned, "enemy reuse clears friendly tag");
    _fx.sprite_index = probe_sprite; _fx.image_alpha = 0.8; _fx.damage = 42;
    opacity_pixel(_fx, 2, 0.8);
    with (_fx) instance_destroy();
    with (_card) _fx = instance_create_depth(0, 0, 0, obj_wine_bottle_bomb_explode);
    var _chain = noone;
    with (_fx) _chain = instance_create_depth(0, 0, 0, obj_wine_bottle_bomb_explode);
    opacity_assert(_chain.friendly_attack_owned, "chain explosion retains ownership");
    global.obj_pool_enabled = false;
    with (_card) _fx = instance_create_depth(0, 0, 0, obj_coke_bomb_explode);
    opacity_assert(_fx.friendly_attack_owned, "unpooled friendly shared explosion tagged");
    with (_enemy) _fx = instance_create_depth(0, 0, 0, obj_coke_bomb_explode);
    opacity_assert(!_fx.friendly_attack_owned, "unpooled enemy shared explosion excluded");

    ini_open("opacity_probe.ini");
    friendly_attack_opacity_load();
    opacity_assert(global.friendly_attack_opacity == 1, "old config default");
    ini_write_real("settings", "friendly_attack_opacity", -1);
    friendly_attack_opacity_load();
    opacity_assert(global.friendly_attack_opacity == 0, "config lower bound");
    ini_write_real("settings", "friendly_attack_opacity", 2);
    friendly_attack_opacity_load();
    opacity_assert(global.friendly_attack_opacity == 1, "config upper bound");
    ini_close();
    file_delete("opacity_probe.ini");
    global.friendly_attack_opacity = 0.37;
    friendly_attack_opacity_save();
    ini_open("config.ini");
    friendly_attack_opacity_load();
    opacity_assert(abs(global.friendly_attack_opacity - 0.37) < 0.001, "setting round trip");
    ini_close();
    file_delete("config.ini");
    show_debug_message("ATTACK_OPACITY_PASS");
    game_end();
}
