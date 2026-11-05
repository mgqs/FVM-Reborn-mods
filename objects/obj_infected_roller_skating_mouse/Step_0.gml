if (hp > (maxhp - helmet_hp))
{
    sprite_index = spr_infected_roller_skating_mouse_helmet;
    attack_anim = 6;
    hit_sound = snd_hit3;
}
else
{
    sprite_index = spr_infected_roller_skating_mouse;
    attack_anim = 4;
    hit_sound = snd_hit1;
}

if (!arm_dropped && (hp / (maxhp - helmet_hp)) <= hurt_rate)
{
    var inst = instance_create_depth(x - 25, y - 95, depth - 1, obj_infected_arms_drop);
    arm_dropped = true;
}

if (hp <= (maxhp - helmet_hp) && !armor_dropped)
{
    var inst = instance_create_depth(x - 25, y - 175, depth - 1, obj_enemy_armor);
    inst.ground_y = y - 38;
    inst.type = "helmet";
    inst.x_speed = random_range(3, 5);
    inst.y_speed = random_range(-5, -8);
    inst.cgravity = 0.8;
    inst.sprite_index = spr_infected_roller_helmet;
    armor_dropped = true;
}

// ==== 死亡表现修复（2026-11-05）====
// 存活时头盔/无头盔会切换精灵并把 attack_anim 改成 6 / 4。
// 头盔版精灵只有 32 帧、没有死亡帧；而父类的死亡索引是
// `mod(death_anim) + move_anim*2 + attack_anim*2`，attack_anim 被改成 4 后起点变成 28
// （死亡美术其实在 32..40），淡出阈值要 image_index 恰好等于算出来的末帧才成立
// → 偶发「尸体躺在地上一直不消失」。
// 这里在父类之前把死亡态的帧参数据还原成美术实际布局（41 帧：0..19 待机/移动、20..31 攻击、32..40 死亡），
// 并加一道超时兜底，保证尸体会被清掉。
if state == ENEMY_STATE.DEAD && !ash_death {
    sprite_index = spr_infected_roller_skating_mouse;
    attack_anim = 6;
    if timer > death_anim * flash_speed + 60 {
        instance_destroy();
    }
}

event_inherited();
