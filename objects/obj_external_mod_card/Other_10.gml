// Explicit instance values support copies/revival without resetting to the player's selected level.
var data = get_plant_upgrade(plant_id, shape, current_level);
if (is_undefined(data)) exit;
var values = ["hp", "atk", "cost", "range", "cooldown", "cycle"];
for (var i = 0; i < array_length(values); i++) variable_instance_set(id, values[i], data[? values[i]]);
if (!is_undefined(mod_definition.skill)) {
    var sk = mod_definition.skill;
    variable_instance_set(id, sk.property, sk.values[clamp(skill, 0, 8)]);
}
max_hp = hp;
_prev_hp = hp;
origin_cycle = cycle;
if (instance_exists(banding_star_obj)) instance_destroy(banding_star_obj);
if (current_level >= 4) {
    var stars = instance_create_depth(x, y - 5, depth - 1, obj_stars);
    var sprites = [spr_star_4, spr_star_5, spr_star_6, spr_star_7, spr_star_8, spr_star_9, spr_star_10, spr_star_11, spr_star_12, spr_star_13, spr_star_14, spr_star_15, spr_star_16, spr_star_17, spr_star_18];
    stars.sprite_index = sprites[clamp(current_level - 4, 0, array_length(sprites) - 1)];
    stars.parent_card = id;
    banding_star_obj = stars;
}
