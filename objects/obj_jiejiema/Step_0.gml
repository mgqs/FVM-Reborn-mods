// obj_jiejiema Step 事件
// 只做三件事：持续时间倒计时 → 领队选举 → 结界引用兜底。
if (global.is_paused)
    exit;

event_inherited();

// ── 持续时间 ──────────────────────────────────────────────────────────────
jj_life--;
if (jj_life <= 0)
{
    instance_destroy();
    exit;
}
// 最后 1.5 秒闪一下，让玩家知道马要没了（不是被打死的那种消失）
if (jj_life <= 90)
{
    jj_blink++;
    image_alpha = (floor(jj_blink / 8) mod 2 == 0) ? 0.45 : 1;
}

// ── 技能动画态 ────────────────────────────────────────────────────────────
// 结界每次结算（obj_jiejiema_field 的 jj_cycle）会给场上所有马点亮 jj_skill_timer，
// 这里把它换成一次 ATTACK 态 —— 待机段只播呼吸，不播施法姿势（见 Create_0 的帧结构注释）。
if (jj_skill_timer > 0)
{
    jj_skill_timer--;
    state = CARD_STATE.ATTACK;
}
else
{
    state = CARD_STATE.IDLE;
}

// ── 领队选举 ──────────────────────────────────────────────────────────────
// 场上 id 最小的那只负责建结界。用 id 而不是「谁先放」：
//   id 单调递增，一张卡铲了又放会拿到新 id，选举结果永远稳定、不会两只同时建。
if (!instance_exists(jj_field))
{
    jj_field = noone;
    var _leader = noone;
    with (obj_jiejiema)
    {
        if (hp > 0 && (_leader == noone || id < _leader))
            _leader = id;
    }
    if (_leader == id)
    {
        // 初值 -9 = 「地面之上、卡片之下」；结界对象自己会在 Step 里按最上一行重算
        jj_field = instance_create_depth(x, y, -9, obj_jiejiema_field);
        jj_field.jj_owner = id;
    }
}
