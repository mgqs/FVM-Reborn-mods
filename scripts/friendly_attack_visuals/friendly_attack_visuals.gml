/// Display-only multiplier. Never write image_alpha: gameplay and pooled fades
/// must keep their original state, including while attacks are fully hidden.
global.friendly_attack_opacity = 1;
global._friendly_attack_kind_cache = [];

/// 0 = unrelated, 1 = friendly attack, 2 = shared effect, 3 = friendly source.
/// Cache by object type, not instance ID (instances can change type in the pool).
function friendly_attack_visual_kind(_obj) {
    var _key = real(_obj);
    if (_key < 0) return 0;
    if (_key < array_length(global._friendly_attack_kind_cache)) {
        var _cached = global._friendly_attack_kind_cache[_key];
        if (_cached > 0) return _cached - 1;
    }

    static _effects = [
        obj_12yinliao_effect, obj_aurora_dead_explode, obj_aurora_effect,
        obj_baiyang_effect, obj_bbq_mouse_burn, obj_beefhotpot_bullet,
        obj_burn_cell, obj_burn_effect, obj_chocolatecannon_bullet,
        obj_chocolatecannon_bullet_effect, obj_chunsun_launch_fx,
        obj_clotho_effect, obj_clotho_star_effect, obj_coffeecup_bullet_effect,
        obj_coffeepot_bullet, obj_corn_shooter_effect, obj_corn_shooter_effect_1,
        obj_corn_shooter_effect_2, obj_currylobstercannon_bullet,
        obj_dangdanghu_bullet, obj_dangdanghu_fire, obj_dianman_effect,
        obj_doumaobang_cat, obj_durian_effect, obj_eggboilerpult_bullet_effect,
        obj_eightcake_burn_cell, obj_fashishe_poison_cell, obj_fire_bullet_effect,
        obj_guihuajiu_boom, obj_guihuajiu_drunk, obj_haiyang_god_effect,
        obj_howitzer_bullet,
        obj_hufa_god_effect, obj_hundun_god_effect, obj_huojianzhu_boom,
        obj_iceeggboilerpult_bullet_effect, obj_icelongbao_bullet_effect,
        obj_kettle_slowdown_effect, obj_lantern_burn_effect,
        obj_lightning_baguette_thunder, obj_meiweijishiqi_effect,
        obj_mianbao_boom, obj_mianbao_burn_fx, obj_odenpot_bullet_vertical,
        obj_panduola_effect, obj_panfriedbun_bullet_effect,
        obj_ronghedan_god_poison_effect, obj_ronghedapao_bullet,
        obj_ronghedapao_bullet_effect, obj_ronghehuopen_cold,
        obj_ronghehuopen_ice_ctrl, obj_ronghesanxian_burn_ctrl,
        obj_ronghesanxian_burn_fx, obj_rongheshuanggu_effect,
        obj_rongheshuanggu_effect_air, obj_saladpult_bullet_effect,
        obj_save_god01_e, obj_save_god23_e2, obj_sh_b, obj_sh_b_1,
        obj_sh_b_2, obj_sh_b_3, obj_sh_b_3_e, obj_shuanggu_effect,
        obj_shuanggu_effect_air, obj_shuiping_explode, obj_spicypot_bullet,
        obj_stinkytofupult_bullet_effect, obj_takoyaki_bullet_effect,
        obj_tanchitu_rabbit, obj_tangchaolizi_bullet_effect,
        obj_tanghulu_bullet_effect, obj_tianxie_alt, obj_tianxie_needle,
        obj_tunshilong_boom, obj_unfreeze_effect, obj_waterpipe_bullet_effect,
        obj_xiangshui_god_effect, obj_xiaolongbao_bullet_effect,
        obj_light_atk_effect, obj_light_atk_effect_1, obj_light_explode,
        obj_zodiac_effect, obj_gongjiang_god_effect, obj_laipishe_effect,
        obj_shuangrenshe_zhansha_effect, obj_xuanfengniu_effect,
        obj_pineapple_explosive_bread_explosion,
        obj_slowdown_gem_effect, obj_laser_gem_effect, obj_laser_gem_spawn,
        obj_bomb_gem_effect, obj_holy_gem_effect, obj_starlight_gem_effect,
        obj_freeze_gem_effect, obj_freeze_gem_spawn
    ];
    // These sprites are also spawned by enemies. Only tagged friendly spawns
    // follow the setting; an untagged/enemy spawn remains fully visible.
    static _shared = [obj_coke_bomb_explode, obj_wine_bottle_bomb_explode,
        obj_arno_bullet_effect, obj_knock_back_effect, obj_mouse_clip_explode];
    static _sources = [obj_player_character, obj_laser_gem,
        obj_bomb_gem, obj_holy_gem, obj_starlight_gem, obj_freeze_gem];

    var _kind = 0;
    if (_obj == obj_bullet_parent || object_is_ancestor(_obj, obj_bullet_parent)
        || array_get_index(_effects, _obj) >= 0) _kind = 1;
    else if (array_get_index(_shared, _obj) >= 0) _kind = 2;
    else if (_obj == obj_card_parent || object_is_ancestor(_obj, obj_card_parent)
        || array_get_index(_sources, _obj) >= 0) _kind = 3;
    global._friendly_attack_kind_cache[_key] = _kind + 1;
    return _kind;
}

function friendly_attack_visual_owned(_inst) {
    if (is_struct(_inst) || !instance_exists(_inst)) return false;
    var _kind = friendly_attack_visual_kind(_inst.object_index);
    if (_kind == 1 || _kind == 3) return true;
    return _kind == 2 && variable_instance_exists(_inst, "friendly_attack_owned")
        && _inst.friendly_attack_owned;
}

/// Called for both fresh and pooled spawns; always overwrite a shared effect's
/// ownership so an enemy cannot inherit a friendly tag from a recycled instance.
function friendly_attack_visual_tag_spawn(_inst) {
    if (instance_exists(_inst) && friendly_attack_visual_kind(_inst.object_index) == 2) {
        _inst.friendly_attack_owned = friendly_attack_visual_owned(self);
    }
}

function friendly_attack_visual_alpha() {
    if (global.friendly_attack_opacity >= 1) return 1;
    if (is_struct(self) || !instance_exists(self)) return 1;
    var _kind = friendly_attack_visual_kind(object_index);
    if (_kind == 1 || (_kind == 2 && friendly_attack_visual_owned(self))) {
        return global.friendly_attack_opacity;
    }
    return 1;
}

function friendly_attack_opacity_load() {
    var _value = ini_read_real("settings", "friendly_attack_opacity", 1);
    if (is_nan(_value) || is_infinity(_value)) _value = 1;
    global.friendly_attack_opacity = clamp(_value, 0, 1);
}

function friendly_attack_opacity_save() {
    ini_open("config.ini");
    ini_write_real("settings", "friendly_attack_opacity", global.friendly_attack_opacity);
    ini_close();
}
