// 石榴爆爆冰 —— 瞬发引爆
// 待机：父对象播 idx 0..idle_anim（0..8 生长、9..21 成熟呼吸，见 tools/fix_shiliu_sprite_order.py）；
// explode_timer 归零 → 切 ATTACK 态，从 idx 22（爆炸段首帧）开始播。爆炸段由本对象自己逐帧推进（anim_frame），
// 不再依赖父对象 ATTACK 分支的 image_index 夹逼（它越界后回落到 idle_anim+1，
// 光看 image_index 判「播完」永远判不到）。播到末帧即结算并销毁。
if (global.is_paused) {
    exit;
}

// ========== 索敌：作用范围内有老鼠才开始生长 ==========
// 用户口径（2026-11-13）：范围内有老鼠先生长、再爆炸。没有老鼠就一直保持幼苗帧不动，
// 引信也不走（否则卡会空放）。感知范围取碾压索敌范围 crush_radius。
// 一旦开长就锁 shiliu_armed，老鼠中途走掉也把这一发走完。
//
// 判定**不查 can_hit_ash**：`can_target_on("all", "diver"/"underground")` 都返回 false
//（那几个类型只对 throw / track 放行），拿它当索敌条件会让卡片对着潜水鼠 / 钻地鼠永远不长。
// 这里只看「这只鼠是不是这张卡的作用对象」—— 陆、地、非主流、障碍、幽灵；
// 真正能不能打（防爆 / 免疫）留给爆炸时的 can_hit_ash 过滤。
if (!shiliu_armed) {
    var _mc = grid_col;
    var _mrow = grid_row;
    var _mr = crush_radius;
    var _has_target = false;

    with (obj_enemy_parent) {
        if (hp > 0
            && abs(grid_col - _mc) <= _mr && abs(grid_row - _mrow) <= _mr) {
            var _et = target_type;
            if (_et == "normal" || _et == "diver" || _et == "dance"
                || _et == "obstacle" || _et == "underground" || _et == "invisible") {
                _has_target = true;
            }
        }
    }

    if (_has_target) shiliu_armed = true;
}

// ========== 引爆切换（放在 event_inherited 之前：父对象按 state 推进动画）==========
// 冰冻期间引信不走（被冻住的卡不该炸）；已进入爆炸段则不再回退。
if (shiliu_armed && !is_frozen && state != CARD_STATE.SLEEP) {
    explode_timer--;

    if (explode_timer <= 0 && state != CARD_STATE.ATTACK) {
        invincible = true;             // 引爆阶段免疫，防止被鼠啃掉导致炸不出来
        state = CARD_STATE.ATTACK;
        image_index = idle_anim + 1;   // 爆炸段首帧（idx 22）
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

// ========== 生长段只播一次 ==========
// 父对象的 IDLE 是 0..idle_anim 死循环，播到成熟段末帧后会回卷到 idx 0（幼苗）。
// 石榴是一次性卡，回卷会让果实突然缩小再长大一遍；这里把回卷目标改到成熟段首帧，
// 于是「生长 9 帧只播一次 + 成熟段无限呼吸」。
// 还没等到老鼠（!shiliu_armed）时把帧压在幼苗 idx 0：父类会自己往前推，这里每帧压回去。
if (state == CARD_STATE.IDLE) {
    if (!shiliu_armed) {
        image_index = 0;
    }
    else if (shiliu_mature_start < idle_anim) {
        if (image_index >= shiliu_mature_start) shiliu_mature_locked = true;

        if (shiliu_mature_locked && image_index < shiliu_mature_start) {
            var _mature_len = idle_anim - shiliu_mature_start + 1;
            image_index = shiliu_mature_start + (image_index mod _mature_len);
        }
    }
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
