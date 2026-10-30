// 遁地（如谛听常规移动/技能1钻入段）期间无敌，不受伤害也跳过共享血同步。
if (variable_instance_exists(id, "invincible") && invincible) exit;

event_inherited();

if (instance_exists(ly_shared_boss_peer)) {
    var _shared_hp = max(0, hp);
    with (ly_shared_boss_peer) {
        hp = min(hp, _shared_hp);
        if (_shared_hp <= 0) hp = 0;
    }
}
