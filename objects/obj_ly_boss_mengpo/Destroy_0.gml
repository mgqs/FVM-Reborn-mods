event_inherited();

// 清理孟婆鼠召唤的茶树与天气演出
with (obj_ly_boss_fx) {
    if (fx_kind == "mengpo_tea_tree_live"
        || fx_kind == "mengpo_rain_live"
        || fx_kind == "mengpo_strong_wind_live"
        || fx_kind == "mengpo_wind_line"
        || fx_kind == "mengpo_wind_hit_live"
        || fx_kind == "mengpo_wind_mist_live") {
        instance_destroy();
    }
}

// 降雨滋生的蘑菇随 BOSS 一同消失
with (obj_ly_mengpo_mushroom) instance_destroy();
