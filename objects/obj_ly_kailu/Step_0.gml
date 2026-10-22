if (global.is_paused) exit;
// 死亡当帧强制重算夜晚（不靠 Create 初始化时可能的缓存，确保 level_file 就绪后拿到正确值）
if (!ly_soul && hp <= 0) {
    ly_night = longyuan_is_night();
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
        if (!ly_soul && longyuan_is_night()) longyuan_change_soul();
        else { image_alpha -= 0.08; if (image_alpha <= 0) instance_destroy(); }
    }
    exit;
}
if (hp <= 0) { longyuan_begin_death(); exit; }
if (is_frozen || is_stun || is_scare) exit;

if (ly_boss_soul) {
    x += move_speed * move_speed_modify / (is_slowdown ? 2 : 1);
    longyuan_play(longyuan_move_action());
    longyuan_animate();
    if (grid_col >= global.grid_cols - 1) {
        if (instance_exists(ly_absorb_boss)) {
            var _remaining_hp = hp;
            var _absorbed_boss = ly_absorb_boss;
            with (_absorbed_boss) hp = min(maxhp, hp + _remaining_hp);
            if (instance_exists(_absorbed_boss.ly_shared_boss_peer)) {
                with (_absorbed_boss.ly_shared_boss_peer) hp = _absorbed_boss.hp;
            }
        }
        instance_destroy();
    }
    exit;
}

ly_cooldown = max(0, ly_cooldown - 1);
ly_dodge_cooldown = max(0, ly_dodge_cooldown - 1);
var _speed = move_speed * move_speed_modify / (is_slowdown ? 2 : 1);

if (ly_mode == "spawn" || ly_mode == "appear" || ly_mode == "drop") {
    longyuan_animate();
    if (ly_done) {
        {

            ly_mode = "walk"; ly_action = "";
        }
    }
    exit;
}

// 魂体（夜晚）：行走或冲刺中只要与卡片同格接触，就摧毁该卡并自爆（第4/8列冲刺能力同样保留）。
if (ly_soul) {
    var _soul_card = longyuan_card_in_cell(grid_col, grid_row);
    if (instance_exists(_soul_card)) {
        longyuan_destroy_card(_soul_card);
        ash_death = true;
        longyuan_begin_death();
        exit;
    }
}

if (ly_mode == "dash") {
    if (!ly_soul) {
        // 冲刺过程中遇到的第一张卡片：造成 100 啃咬伤害（不销毁卡片、不自爆），
        // 冲刺立即结束并贴到该卡右侧，下一帧转入普通啃咬（每次 atk=10）。
        var _dash_card = longyuan_card_in_cell(grid_col, grid_row);
        if (instance_exists(_dash_card)) {
            longyuan_damage_plant(_dash_card, LY_KAILU_DASH_DAMAGE);
            x = _dash_card.x + global.grid_cell_size_x * 0.5;
            ly_mode = "walk"; ly_action = "";
            exit;
        }
    }
    x -= max(1, _speed * 2);
    longyuan_animate();
    if (x <= ly_dash_target_x) { ly_mode = "walk"; ly_action = ""; }
    exit;
}

var _dash_col = array_get_index(ly_dash_cols, grid_col);
if (_dash_col != -1 && array_get_index(ly_dashed_cols, grid_col) == -1) {
    array_push(ly_dashed_cols, grid_col);
    ly_dash_target_x = x - global.grid_cell_size_x * LY_KAILU_DASH_DIST;
    ly_mode = "dash";
    // 冲刺距离 3 格 ≈ 180 像素（约 150 帧），但精灵只有 8 帧，必须循环播放否则播完立即静止
    longyuan_play(ly_soul ? longyuan_variant("正常前进", "破损前进") : longyuan_variant("正常冲刺", "破损冲刺"), false);
    exit;
}

target_plant = longyuan_find_plant(false);
if (ly_soul) target_plant = noone;

if (instance_exists(target_plant)) {
    ly_mode = "attack";
    longyuan_play(longyuan_attack_action());
    longyuan_animate();
    var _clip = ly_anims[$ ly_action];
    var _hit_frame = floor((_clip[2] - _clip[1] + 1) / 2);
    if (!ly_hit && ly_frame >= _hit_frame) { longyuan_damage_plant(target_plant, atk); ly_hit = true; }
    if (ly_done && ly_frame >= max(_clip[2] - _clip[1] + 1, atk_cycle * 10 / game_get_speed(gamespeed_fps))) {
        ly_frame = 0; ly_hit = false;
        x = target_plant.x - global.grid_cell_size_x * 0.5;
        ly_mode = "walk"; ly_action = "";
    }
    exit;
}
ly_mode = "walk";
longyuan_play(longyuan_move_action());
x -= _speed;
longyuan_animate();
