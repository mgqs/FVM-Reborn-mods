// 石榴爆爆冰 —— 瞬发引爆
// 待机：父对象播 0..idle_anim（果实微动）；
// explode_timer 归零 → 切 ATTACK 态。爆炸段由本对象自己逐帧推进（anim_frame），
// 不再依赖父对象 ATTACK 分支的 image_index 夹逼（它越界后回落到 idle_anim+1，
// 光看 image_index 判「播完」永远判不到）。播到末帧即结算并销毁。
if (global.is_paused) {
    exit;
}

// ========== 引爆切换（放在 event_inherited 之前：父对象按 state 推进动画）==========
// 冰冻期间引信不走（被冻住的卡不该炸）；已进入爆炸段则不再回退。
if (!is_frozen && state != CARD_STATE.SLEEP) {
    explode_timer--;

    if (explode_timer <= 0 && state != CARD_STATE.ATTACK) {
        invincible = true;             // 引爆阶段免疫，防止被鼠啃掉导致炸不出来
        state = CARD_STATE.ATTACK;
        image_index = idle_anim + 1;   // 爆炸段首帧（idx 9）
        attack_timer = 0;
        anim_frame = 0;
        anim_timer = 0;
    }
}

event_inherited();

if (hp <= 0) {
    instance_destroy();
    exit;
}

// ========== 爆炸段自驱动画 → 播完即结算 ==========
if (state == CARD_STATE.ATTACK) {
    var current_flash_speed = flash_speed;
    if (is_slowdown) current_flash_speed = flash_speed * 2;

    anim_timer++;
    if (anim_timer >= current_flash_speed) {
        anim_timer = 0;
        anim_frame++;
        if (anim_frame >= attack_anim) {
            // 末帧已经画过一整个 flash 周期，结算
            image_index = idle_anim + attack_anim;
            if (!triggered) {
                triggered = true;
                event_user(1);
            }
            instance_destroy();
            exit;
        }
    }
    // 覆盖父对象写的 image_index，锁在爆炸段内
    image_index = idle_anim + 1 + anim_frame;
}
