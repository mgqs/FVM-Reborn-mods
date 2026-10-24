// EndStep：覆盖父类（不执行难度血量修正、不响应岩浆/粘液减速）
if (global.is_paused) exit;

// 将本帧收集到的全部攻击伤害转发给绑定老鼠
if (decoy_pending > 0
    && instance_exists(decoy_card) && !decoy_card.zodiac_dying
    && instance_exists(decoy_target) && decoy_target.hp > 0) {
    // 傀儡马的攻击倍率作用于代理收集到的实际伤害，再转发给绑定老鼠。
    var _kdata = get_plant_data_with_skill(decoy_card.plant_id,decoy_card.shape,decoy_card.current_level,decoy_card.skill);
    var _kmult = _kdata == undefined ? 1 : _kdata[? "atk"];
    var _dmg = decoy_pending * _kmult;
    var _dtype = decoy_type;
    with (decoy_target) {
        damage_amount = _dmg;
        damage_type = _dtype;
        event_user(0);
    }
    // 傀儡马播放受击动画作为命中反馈
    with (decoy_card) {
        if (!zodiac_dying) {
            // 受击动画 17-21
            state = CARD_STATE.ATTACK;
            image_index = idle_anim+1;
            zodiac_hurt_timer = attack_anim*flash_speed;
        }
    }
}
decoy_pending = 0;
decoy_type = "normal";
damage_amount = 0;
damage_type = "";

// 复位：伤害、击退位移、控制状态都不应残留在代理身上
if (instance_exists(decoy_card)) {
    x = decoy_card.x;
    y = decoy_card.y;
    grid_col = decoy_card.grid_col;
    grid_row = decoy_card.grid_row;
}
if (instance_exists(decoy_target) && decoy_target.hp > 0) hp = decoy_target.hp;
state = ENEMY_STATE.NORMAL;
ice_timer = 0;
frozen_timer = 0;
scare_timer = 0;
stun_timer = 0;
is_frozen = false;
is_slowdown = false;
is_scare = false;
is_stun = false;
image_alpha = 0;
