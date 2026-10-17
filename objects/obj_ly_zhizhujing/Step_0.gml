if (global.is_paused) exit;
// 保留父对象注册、状态效果、深度及胜负处理；ACTING禁止旧动画偏移算法。
var _saved_index = image_index;
var _saved_alpha = image_alpha;
state = ENEMY_STATE.ACTING;
event_inherited();
if (!instance_exists(id)) exit;
image_index = _saved_index;
image_alpha = _saved_alpha;
state = ly_mode == "dead" ? ENEMY_STATE.DEAD : ENEMY_STATE.ACTING;
if (ly_mode == "dead") {
    longyuan_animate();
    if (ly_done) {
        if (!ly_soul && !ash_death && ly_night) longyuan_change_soul();
        else { image_alpha -= 0.08; if (image_alpha <= 0) instance_destroy(); }
    }
    exit;
}
if (hp <= 0) { longyuan_begin_death(); exit; }
if (is_frozen || is_stun || is_scare) exit;
var _air_speed_multiplier = longyuan_air_speed_multiplier();
{
    ly_mode = "spider";
    target_plant = longyuan_find_plant(false);
    if (instance_exists(target_plant)) {
        var _spider_dx = target_plant.x - x;
        if (abs(_spider_dx) > 18) x += sign(_spider_dx) * 1.8 * _air_speed_multiplier;
        var _spider_action = ly_soul ? "正常抱住物品" : "缠绕卡片";
        longyuan_play(_spider_action);
        longyuan_animate();
        if (ly_frame >= 5 && !ly_webbed) {
            with (target_plant) {
                sprite_index = spr_zhizhujing_wang;
                longyuan_webbed = true;
                if (variable_instance_exists(id, "state")) state = CARD_STATE.SLEEP;
            }
            ly_webbed = true;
        }
    } else {
        longyuan_play("正常待机");
        longyuan_animate();
    }
    exit;
}
