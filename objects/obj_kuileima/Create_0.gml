event_inherited();
plant_id = "kuileima";
obj_type = object_index;
event_user(0);

plant_type = "normal";
feature_type = "normal";
sprite_index = spr_kuileima;
if (shape == 1) sprite_index = spr_kuileima_1;
else if (shape >= 2) sprite_index = spr_kuileima_2;
image_xscale = 1.8;
image_yscale = 1.8;
// 0-16待机 17-21受击 22-末帧死亡
idle_anim = 16;
attack_anim = 5;
flash_speed = 5;
zodiac_timer = 0;
zodiac_age = 0;
zodiac_dying = false;
zodiac_death_timer = 0;
zodiac_hurt_timer = 0;
zodiac_previous_hp = hp;

// 锁定最高血量老鼠（优先BOSS），创建巫毒代理承接攻击伤害
var kt_list = [];
for (var kt_i = 0; kt_i < instance_number(obj_enemy_parent); kt_i++) {
    var kt_e = instance_find(obj_enemy_parent,kt_i);
    if (instance_exists(kt_e) && kt_e.hp > 0) array_push(kt_list,kt_e);
}
for (var kt_i = 0; kt_i < instance_number(obj_kuileima_decoy); kt_i++) {
    var kt_d = instance_find(obj_kuileima_decoy,kt_i);
    if (instance_exists(kt_d) && kt_d.hp > 0 && !array_contains(kt_list,kt_d)) array_push(kt_list,kt_d);
}
zodiac_target = noone;
for (var kt_i = 0; kt_i < array_length(kt_list); kt_i++) {
    var kt_e = kt_list[kt_i];
    // 血量最高优先；血量相同时BOSS优先
    if (!instance_exists(zodiac_target) || kt_e.hp > zodiac_target.hp
        || (kt_e.hp == zodiac_target.hp && kt_e.is_boss && !zodiac_target.is_boss)) zodiac_target = kt_e;
}
zodiac_decoy = noone;
if (instance_exists(zodiac_target) && zodiac_target.hp > 0) {
    zodiac_decoy = instance_create_depth(x,y,depth,obj_kuileima_decoy);
    zodiac_decoy.decoy_card = id;
    // 立即继承绑定老鼠的完整身份（BOSS就是BOSS、精英就是精英），不要等到下一帧
    zodiac_decoy.decoy_sync_identity(zodiac_target);
}
zodiac_effects = [];
// effect2_2/effect3_1 为死亡专属特效，放下时不播放（形态2不再创建常驻光环）
// 常驻光环精灵当前资源包中不存在：沿用运行时按名查找，缺资源时静默不建特效
if (shape != 2) {
    var ke_halo_name = "spr_kuileima_effect";
    if (shape != 0) ke_halo_name = "spr_kuileima_effect2_1";
    var ke_halo_spr = asset_get_index(ke_halo_name);
    if (ke_halo_spr > -1) {
        var e = instance_create_depth(x,y,-3000,obj_zodiac_effect);
        e.sprite_index = ke_halo_spr;
        e.life = 2147483647;
        e.image_index = 0;
        e.image_speed = 0.5;
        array_push(zodiac_effects,e);
    }
}
no_revive_record = true;
