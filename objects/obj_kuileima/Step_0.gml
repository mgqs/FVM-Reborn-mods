if (global.is_paused) exit;

// 傀儡马当前攻击力倍率（用于按比例转移受伤）
var _kdata = get_plant_data_with_skill(plant_id,shape,current_level,skill);
var _kmult = 1;
if (_kdata != undefined) _kmult = _kdata[? "atk"];

// 死亡动画期间推进帧序；存活期间处理受击计时与伤害转移
if (zodiac_dying) {
    if (hp <= 0) hp = 1; // 死亡动画期间免疫后续伤害
    zodiac_death_timer++;
    if (zodiac_death_timer >= flash_speed) {
        zodiac_death_timer = 0;
        if (image_index < sprite_get_number(sprite_index)-1) image_index++;
        else instance_destroy(); // 死亡动画播放完毕，销毁并触发死亡特效
    }
} else {
    if (zodiac_hurt_timer > 0) {
        zodiac_hurt_timer--;
        if (zodiac_hurt_timer <= 0 && state == CARD_STATE.ATTACK) {
            state = CARD_STATE.IDLE;
            image_index = 0;
        }
    }
    if (hp < zodiac_previous_hp) {
        // 受到的伤害按攻击倍率转移给绑定的老鼠
        if (instance_exists(zodiac_target) && zodiac_target.hp > 0) {
            var kd_dmg = (zodiac_previous_hp-hp)*_kmult;
            with (zodiac_target) {
                damage_amount = kd_dmg;
                damage_type = "pierce";
                event_user(0);
            }
        }
    }
    zodiac_previous_hp = hp;
    if (hp <= 0) {
        // 进入死亡动画：保持存活以避免父类立即销毁，动画结束后再真正销毁
        zodiac_dying = true;
        zodiac_death_timer = 0;
        zodiac_hurt_timer = 0;
        hp = 1;
        zodiac_previous_hp = hp;
        state = CARD_STATE.DEAD;
        image_index = idle_anim+attack_anim+1; // 死亡帧起点（22）
    }
}

event_inherited();
if (hp <= 0) exit;

// 代理被吞噬/吹走等直接销毁时（不经过伤害转发），绑定目标存活则立即重建
if (!zodiac_dying && !instance_exists(zodiac_decoy)
    && instance_exists(zodiac_target) && zodiac_target.hp > 0) {
    zodiac_decoy = instance_create_depth(x,y,depth,obj_kuileima_decoy);
    zodiac_decoy.decoy_card = id;
    zodiac_decoy.decoy_sync_identity(zodiac_target);
}

zodiac_age++;
// 光环特效跟随卡片
for (var i = 0; i < array_length(zodiac_effects); i++) {
    var e = zodiac_effects[i];
    if (instance_exists(e)) {e.x = x; e.y = y;}
}
if (zodiac_dying) exit;
// 持续时间结束或目标死亡时自毁
if (!instance_exists(zodiac_target) || zodiac_target.hp <= 0 || zodiac_age >= origin_cycle) {
    zodiac_dying = true;
    zodiac_death_timer = 0;
    zodiac_hurt_timer = 0;
    hp = 1;
    zodiac_previous_hp = hp;
    state = CARD_STATE.DEAD;
    image_index = idle_anim+attack_anim+1;
    exit;
}
if (zodiac_age mod 15 == 1) {
    // 多节原尺寸锁链从卡片连接指向绑定的老鼠
    var chain_spr = spr_kuileima_chain;
    if (shape == 1) chain_spr = spr_kuileima_chain_1;
    else if (shape >= 2) chain_spr = spr_kuileima_chain_2;
    if (chain_spr > -1) {
        var chain_dir = point_direction(x,y-30,zodiac_target.x,zodiac_target.y-30);
        var chain_dist = point_distance(x,y-30,zodiac_target.x,zodiac_target.y-30);
        var chain_count = max(1,ceil(chain_dist/sprite_get_width(chain_spr)));
        var chain_spacing = chain_dist/chain_count;
        for (var i = 0; i < chain_count; i++) {
            // 锁链放在卡片下层（depth+5），避免顶层链节画布盖住卡片与星级贴图
            var ce = instance_create_depth(x+lengthdir_x(chain_spacing*(i+0.5),chain_dir),y-30+lengthdir_y(chain_spacing*(i+0.5),chain_dir),depth+5,obj_zodiac_effect);
            ce.sprite_index = chain_spr;
            ce.life = 15;
            ce.image_index = 0;
            ce.image_speed = 0.5;
            ce.image_angle = chain_dir;
            ce.image_xscale = 1;
            ce.image_yscale = 1;
        }
    }
}
