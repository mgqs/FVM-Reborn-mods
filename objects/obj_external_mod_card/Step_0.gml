if (global.is_paused) exit;
event_inherited();
if (!instance_exists(id) || hp <= 0 || is_frozen || state == CARD_STATE.SLEEP) exit;
if (!mod_started && grid_col >= 0 && grid_row >= 0) {
    mod_started = true;
    external_mod_callback(id, "on_create");
    if (!instance_exists(id)) exit;
}
// Snapshot timers before callbacks: callbacks may append new timers safely.
var old_timers = mod_timers;
mod_timers = [];
var due = [];
for (var i = 0; i < array_length(old_timers); i++) {
    var t = old_timers[i];
    t.ticks--;
    if (t.ticks <= 0) array_push(due, t.name);
    else array_push(mod_timers, t);
}
for (var i = 0; i < array_length(due); i++) {
    external_mod_callback(id, "on_timer", {name: due[i]});
    if (!instance_exists(id)) exit;
}
external_mod_callback(id, "on_step");
if (!instance_exists(id)) exit;
var anim = mod_animation;
var old = mod_animation_frame;
var next = old + anim.fps / 60 / (is_slowdown ? 2 : 1);
var count = sprite_get_number(sprite_index);
for (var i = 0; i < array_length(anim.events); i++) {
    var evt = anim.events[i];
    // JSON frame 1 means first frame; trigger when playback enters that frame.
    var frame = evt.frame - 1;
    if ((frame == 0 && old == 0) || (frame > old && frame <= next)) {
        var previous_anim = mod_animation_name;
        external_mod_callback(id, "on_animation_event", {name: evt.name, frame: evt.frame, animation: previous_anim});
        if (!instance_exists(id)) exit;
        if (mod_animation_name != previous_anim) exit;
    }
}
if (next >= count) {
    if (anim.loop) next = next mod count;
    else {
        var finished = mod_animation_name;
        external_mod_animate(id, "idle");
        external_mod_callback(id, "on_animation_end", {animation: finished});
        exit;
    }
}
mod_animation_frame = next;
image_index = floor(next);
