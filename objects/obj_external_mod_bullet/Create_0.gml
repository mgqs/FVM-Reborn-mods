event_inherited();
sprite_index = spr_xiao_long_bao;
image_speed = 0;
damage = 0;
damage_type = "normal";
target_type = "normal";
move_speed = 8;
row = 0;
owner_card = noone;
mod_card_id = "";
mod_fps = 12;
slow_ticks = 0;
mod_lifetime = 600;
move_x = move_speed;
move_y = 0;
vertical_remaining = 0;
vertical_limited = false;
burn = undefined;
prev_x = x;
prev_y = y;
target_team = "enemy";
combat_owner = noone;
mod_loop = true;
rules = {
    damage_type: "normal",
    target_filter: {team: "enemy", types: [], explicit_types: false, ground: undefined, air: undefined, mole: undefined, hit_invincible: false},
    hit: {max_hits: 1, repeat_hit: false, repeat_interval_ticks: 30, destroy_on_hit: true},
    reflection: {sources: [], max_count: 0, team: "keep", add_source_atk: true},
    enhancement: {sources: [], max_count: 0, clear_slow: false}
};
hit_count = 0;
bounce_count = 0;
amplify_count = 0;
hit_ids = ds_list_create();
hit_cooldowns = ds_map_create();
bounce_ids = ds_list_create();
amplify_ids = ds_list_create();
mod_age = 0;
