if (hp <= 0 || ly_mode == "dead") exit;
if (invincible) exit;

event_inherited();

// 灯影花糕每命中五次熄灭一团魂火。
if (variable_instance_exists(id, "damage_source_card_id") && damage_source_card_id == "dengying_huagao") {
    ly_fire_hits++;
    if (ly_fire_hits >= 5) {
        ly_fire_hits = 0;
        ly_fire = max(0, ly_fire - 1);
    }
}
