event_inherited();
// 受到的伤害立即按攻击倍率转移给绑定的老鼠，并播放受击动画
if (!zodiac_dying && hp < zodiac_previous_hp) {
    var _kdata = get_plant_data_with_skill(plant_id,shape,current_level,skill);
    var _kmult = _kdata == undefined ? 1 : _kdata[? "atk"];
    if (instance_exists(zodiac_target) && zodiac_target.hp > 0) {
        var oh_dmg = (zodiac_previous_hp-hp)*_kmult;
        with (zodiac_target) {
            damage_amount = oh_dmg;
            damage_type = "pierce";
            event_user(0);
        }
    }
    zodiac_previous_hp = hp;
    // 受击动画 17-21
    state = CARD_STATE.ATTACK;
    image_index = idle_anim+1;
    zodiac_hurt_timer = attack_anim*flash_speed;
}
