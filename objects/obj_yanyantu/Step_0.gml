if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;
// 由场上第一只炎焱兔统一维护受增幅卡片脚下的特效，避免重叠光环重复显示。
if (id == instance_find(obj_yanyantu, 0) && zodiac_age mod 5 == 0) {
    var _flame_targets = ["small_fire", "goblet_lamp", "large_fire", "shuangzi", "warm_birds", "sun_god"];

    with (obj_card_parent) {
        if (variable_instance_exists(id, "plant_id") && array_get_index(_flame_targets, plant_id) >= 0) {
            var _card = id;
            var _covered = false;
            with (obj_yanyantu) {
                var _radius = shape == 2 ? 2 : 1;
                if (hp > 0 && abs(grid_col-_card.grid_col) <= _radius && abs(grid_row-_card.grid_row) <= _radius) {
                    _covered = true;
                }
            }

            var _effect = variable_instance_exists(_card, "yanyantu_effect_id") ? _card.yanyantu_effect_id : noone;
            if (_covered) {
                if (!instance_exists(_effect)) {
                    _effect = instance_create_depth(_card.x, _card.y + 30, _card.depth + 1, obj_zodiac_effect);
                    _effect.sprite_index = spr_yanyantu_effect;
                    _effect.life = 2147483647;
                    _effect.image_index = 0;
                    _effect.image_speed = 0.5;
                    _effect.follow = _card;
                    _effect.follow_y_offset = 30;
                    _effect.yanyantu_target = _card;
                    _card.yanyantu_effect_id = _effect;
                }
            } else if (instance_exists(_effect)) {
                instance_destroy(_effect);
                _card.yanyantu_effect_id = noone;
            }
        }
    }

    // 清理目标卡片被移除、转换或不再属于增幅对象后留下的特效。
    with (obj_zodiac_effect) {
        if (variable_instance_exists(id, "yanyantu_target")) {
            var _target = yanyantu_target;
            if (!instance_exists(_target) || array_get_index(_flame_targets, _target.plant_id) < 0) {
                if (instance_exists(_target)) _target.yanyantu_effect_id = noone;
                instance_destroy();
            }
        }
    }
}
// 每5帧触发一次范围内产火卡片的增幅重算
if (zodiac_age mod 5 == 0 && variable_global_exists("buff_apply_id")) global.buff_apply_id++;
