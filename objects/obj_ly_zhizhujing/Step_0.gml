if (global.is_paused) exit;
// 死亡当帧重算夜晚，避免刷怪瞬间 level_file 未就绪导致 ly_night 固化为 false；夜关强制走化魂死亡。
if (!ly_soul && hp <= 0) {
    ly_night = ly_night || longyuan_is_night();
    if (ly_night) ash_death = false;
}
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
        if (!ly_soul && ly_night) longyuan_change_soul();
        else { image_alpha -= 0.08; if (image_alpha <= 0) instance_destroy(); }
    }
    exit;
}
if (hp <= 0) { longyuan_begin_death(); exit; }
if (is_frozen || is_stun || is_scare) exit;

if (ly_soul) ly_spider_night();
else ly_spider_day();
