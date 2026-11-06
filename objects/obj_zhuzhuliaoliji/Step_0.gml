// obj_zhuzhuliaoliji Step 事件
// 索敌沿用普通海星 coal_starfish 那套（本行任意列 / 右方），2026-11-06 用户定的口径。
if global.is_paused{
    exit
}
event_inherited();

if is_frozen || state == CARD_STATE.SLEEP{
    exit
}

var _fs = flash_speed;
if is_slowdown{
    _fs *= 2
}

// ===== 索敌：和普通海星 coal_starfish 同款（2026-11-06 用户改回）=====
//   「本行任意列，或右方（含出图 1 格）」+ 能打的类型；身后的敌人也认（地精鼠出土后会走过来咬卡）
var _has = false;
with (obj_enemy_parent){
    if ((grid_row == other.grid_row || (grid_col >= other.grid_col && grid_col <= global.grid_cols + 1))
        && can_target_on(other.target_type, target_type)){
        _has = true;
        break;
    }
}

if (_has){
    var _was = (state == CARD_STATE.ATTACK);
    if (attack_timer <= cycle - attack_anim * _fs){
        attack_timer++;
    }
    else if (attack_timer <= cycle){
        attack_timer++;
        state = CARD_STATE.ATTACK;
    }
    else{
        attack_timer = 0;
        state = CARD_STATE.IDLE;
    }

    if (!_was && state == CARD_STATE.ATTACK){
        fired_this_attack = false;
        image_index = idle_anim + 1;
    }

    if (state == CARD_STATE.ATTACK && !fired_this_attack && image_index >= 17){
        fired_this_attack = true;
        event_user(1);
        global.audio.play(snd_shot, 0, 0);
    }
}
else{
    attack_timer = 0;
    fired_this_attack = false;
    state = CARD_STATE.IDLE;
}
