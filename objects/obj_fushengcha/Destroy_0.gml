// obj_fushengcha Destroy 事件：清理光环特效并触发一次增幅重算
for (var i = 0; i < array_length(fushengcha_effects); i++) {
    if (instance_exists(fushengcha_effects[i])) instance_destroy(fushengcha_effects[i]);
}
if (variable_global_exists("buff_apply_id")) global.buff_apply_id++;
event_inherited();
