if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

show_debug_message("zhibuji Other_10 hit: hp=" + string(hp) + "/" + string(maxhp) + " dmg=" + string(damage_amount) + " type=" + string(damage_type));

event_inherited();

// 命中后按当前血量比例判定：首次下降到 85/70/55/40/25/10% 各入队一次（一次性旗，治疗/跳帧不重复触发）。
for (var _i = 0; _i < array_length(ly_shot_thresholds); ++_i) {
    if (!ly_shot_fired[_i] && hp <= maxhp * ly_shot_thresholds[_i]) {
        ly_shot_fired[_i] = true;
        array_push(ly_shot_queue, _i);
        show_debug_message("zhibuji threshold fired idx=" + string(_i) + " queue=" + string(array_length(ly_shot_queue)));
    }
}
