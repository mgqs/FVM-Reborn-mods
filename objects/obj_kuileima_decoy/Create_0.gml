// 傀儡马的巫毒代理：继承敌人父类以便被攻击类卡片的索敌/范围攻击命中，
// 但本身无敌、不可见、不移动、不注册、不掉金币；受到的伤害在EndStep转发给绑定老鼠。
event_inherited();

visible = false;
image_alpha = 0;
sprite_index = -1;

move_speed = 0;
move_speed_modify = 1;
atk = 0;
atk_cycle = 99999;

target_type = "normal";
mouse_id = "";
is_boss = false;
giant_type = false;

hp = 1;
maxhp = 1;
helmet_hp = 0;
helmet_max_hp = 0;
shield_hp = 0;
shield_max_hp = 0;
state = ENEMY_STATE.NORMAL;

// 本帧收集到的伤害（User事件0累加，EndStep统一转发）
decoy_pending = 0;
decoy_type = "normal";
decoy_card = noone;
decoy_target = noone;

// 同步绑定目标的完整身份：创建者绑定后立即调用一次（杜绝创建当帧被当杂兵的窗口），
// 之后每帧Step调用保持同步。BOSS/精英、目标类型、老鼠ID必须与绑定目标完全一致，
// 否则"秒杀非精英""白名单斩杀"等攻击会错误命中代理并经伤害转发秒掉绑定目标。
decoy_sync_identity = function(_t) {
    if (instance_exists(_t)) {
        decoy_target = _t;
        is_boss = _t.is_boss;
        target_type = _t.target_type;
        mouse_id = _t.mouse_id;
        giant_type = _t.giant_type;
        hp = _t.hp;
        maxhp = max(1, _t.maxhp);
    }
}
