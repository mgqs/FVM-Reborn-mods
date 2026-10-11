if (global.is_paused) exit;
event_inherited();
if (hp <= 0) exit;

zodiac_age++;

if (is_frozen || state == CARD_STATE.SLEEP) exit;

// 每攻击间隔的1/3召唤1只飞马，停靠在卡片最右方并从下往上累积，集满3只后一起飞出追踪敌人
zodiac_timer++;
if (zodiac_timer >= cycle/3) {
    zodiac_timer = 0;
    if (zodiac_horses < 3) {
        var b = instance_create_depth(x+34,y-16-zodiac_horses*28,-2500,obj_zodiac_projectile);
        b.kind = "flute";
        b.damage = atk;
        b.base_damage = atk;
        b.shape = shape;
        b.target_id = noone;
        b.move_x = lengthdir_x(8,0);
        b.move_y = lengthdir_y(8,0);
        b.image_angle = 0;
        b.sprite_index = spr_xiandima_bullet;
        if (shape == 1) b.sprite_index = spr_xiandima_bullet_1;
        else if (shape >= 2) b.sprite_index = spr_xiandima_bullet_2;
        b.can_dandantu_store = false;
        b.stored = true;
        b.owner_id = id;
        b.park_index = zodiac_horses;
        array_push(zodiac_stored,b);
        zodiac_horses++;
    }
    if (zodiac_horses == 3) {
        // 全屏索敌：优先BOSS，其次最高血量
        var xd_list = [];
        for (var xd_i = 0; xd_i < instance_number(obj_enemy_parent); xd_i++) {
            var xd_e = instance_find(obj_enemy_parent,xd_i);
            if (instance_exists(xd_e) && xd_e.hp > 0) array_push(xd_list,xd_e);
        }
        for (var xd_i = 0; xd_i < instance_number(obj_kuileima_decoy); xd_i++) {
            var xd_d = instance_find(obj_kuileima_decoy,xd_i);
            if (instance_exists(xd_d) && xd_d.hp > 0 && !array_contains(xd_list,xd_d)) array_push(xd_list,xd_d);
        }
        var t = noone;
        for (var xd_i = 0; xd_i < array_length(xd_list); xd_i++) {
            var xd_e = xd_list[xd_i];
            if (!instance_exists(t) || (xd_e.is_boss && !t.is_boss)
                || (xd_e.is_boss == t.is_boss && xd_e.hp > t.hp)) t = xd_e;
        }
        if (instance_exists(t)) {
            // 有目标才放飞；没有目标时保持停靠，等下个召唤周期再检查
            zodiac_horses = 0;
            for (var n = 0; n < array_length(zodiac_stored); n++) {
                var bb = zodiac_stored[n];
                if (!instance_exists(bb)) continue;
                bb.stored = false;
                bb.owner_id = noone;
                bb.target_id = t;
            }
            zodiac_stored = [];
        }
    }
}
