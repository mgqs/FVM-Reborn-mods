if (global.is_paused) exit;
var _old_x = x;
x -= 6;
life++;
image_index = floor(life * 10 / game_get_speed(gamespeed_fps)) mod 9;
var _blocked = false;
var _bridge = longyuan_bridge_contact(x, y, _old_x, y, lane);
if (instance_exists(_bridge)) { _bridge.hp = 0; with (_bridge) event_user(2); }
// 先检查阻挡者，避免同格卡片先被穿透伤害。
with (obj_card_parent) {
    if (hp > 0 && grid_row == other.lane && x >= other.x - 15 && x <= _old_x + 15
        && (plant_id == "brazier" || (variable_instance_exists(id, "blocks_longyuan_shuttle") && blocks_longyuan_shuttle))) _blocked = true;
}
if (_blocked) { instance_destroy(); exit; }
with (obj_card_parent) {
    if (hp <= 0 || grid_row != other.lane || plant_id == "player" || plant_type == "coffee") continue;
    if (x >= other.x - 15 && x <= _old_x + 15 && array_get_index(other.hit_cards, id) == -1) {
        array_push(other.hit_cards, id);
        longyuan_damage_plant(id, other.damage);
    }
}
if (life > 600 || x < global.grid_offset_x - 100) instance_destroy();
