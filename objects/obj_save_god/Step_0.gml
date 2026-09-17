if (global.is_paused)
    exit;

event_inherited();

if (is_frozen)
    exit;

// 始终保持 IDLE 状态，idle 动画循环播放，不触发攻击
state = CARD_STATE.IDLE;
