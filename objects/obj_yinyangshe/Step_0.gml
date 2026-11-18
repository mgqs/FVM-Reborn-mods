// obj_yinyangshe Step 事件
// 三段式：攻击计时到点 → **起手**（先把攻击动画播到出弹帧）→ 播到第 18 帧才真的吐弹。
// 之所以不在一帧里把 5 / 10 发全放出去：全挤在一帧会变成「一面墙」而不是连发，
// 也不好看清哪一发是带毒的。
// 之所以要等出弹帧：素材的攻击段是有「低头蓄力 → 抬头张嘴 → 甩头吐出」的，
// 原来一到 cycle 就先出弹、动作随后才播，看起来像「先有子弹后有动作」。
if (global.is_paused)
    exit;

event_inherited();

if (is_frozen || state == CARD_STATE.SLEEP)
    exit;

// ── 连发队列 ─────────────────────────────────────────────────────────────
if (array_length(yy_burst) > 0)
{
    yy_burst_gap--;
    if (yy_burst_gap <= 0)
    {
        var _shot = yy_burst[0];
        array_delete(yy_burst, 0, 1);
        yy_fire(_shot.kind, _shot.poison);
        yy_burst_gap = yy_shot_gap;
    }
}

// ── 攻击动画保持 ─────────────────────────────────────────────────────────
if (yy_anim_hold > 0)
    yy_anim_hold--;

// ── 起手：盯着攻击动画，播到「吐」的那一帧才发弹 ─────────────────────────
//   image_index 由父对象推（ATTACK 态下每 flash_speed 帧 +1），所以这里只判定、不数帧：
//   到了 17（素材第 18 帧）就发；yy_charge 归零是兜底（被减速 / 动画卡住也照发）。
if (yy_charge > 0)
{
    yy_charge--;

    if (image_index >= yy_fire_frame || yy_charge <= 0)
    {
        yy_charge = 0;

        // 吐出去之后，把攻击段**剩下**的帧播完再回待机（不再从头补一整轮，
        // 否则会看到「吐完又做一遍起手」）。兜底触发时 image_index 可能还在待机段，
        // 那时按整段长度算，别把待机段也当攻击动作播。
        var _rest = (idle_anim + attack_anim) - image_index;
        if (_rest < 1 || _rest > attack_anim)
            _rest = attack_anim;
        yy_anim_hold = _rest * flash_speed;

        event_user(1);      // Other_11：排这一轮的弹序
    }
}

// ── 攻击节奏 ─────────────────────────────────────────────────────────────
// 只有队列空了才开始攒下一轮，避免「上一轮还没吐完就重置计时」导致漏发。
// 起手期间（yy_charge > 0、队列还是空的）**照样攒计时**：出弹只是晚了半拍，
// 整体攻击周期不会因此被拉长。
// 🔴 这里不能用 exit 提前返回：下面的动画态判定必须每帧都跑到，
//    否则队列非空时 state 会停在 IDLE、攻击段不播，起手永远等不到 image_index 17。
if (array_length(yy_burst) == 0)
{
    if (yy_has_target())
    {
        attack_timer++;
        if (attack_timer >= cycle)
        {
            attack_timer = 0;
            yy_charge = yy_fire_delay;      // 进入起手：先播动画，播到出弹帧再吐
        }
    }
    else
    {
        attack_timer = 0;
    }
}

// ── 动画态（放在最后：起手 / 队列 / 补齐动作任一条成立都算攻击中）────────
//   待机段 idx 0..11、攻击段 idx 12..21，见 Create_0 的注释。
if (yy_charge > 0 || array_length(yy_burst) > 0 || yy_anim_hold > 0)
    state = CARD_STATE.ATTACK;
else
    state = CARD_STATE.IDLE;
