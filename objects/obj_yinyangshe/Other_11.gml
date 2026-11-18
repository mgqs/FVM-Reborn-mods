// obj_yinyangshe 用户事件 1（Other_11）：排这一轮的弹序
//   0 转：阴 5 发（第 1 发带毒）
//   1 转：阴 5 发 + 阳 5 发，阴 / 阳交替（看起来像两条蛇轮流吐）
//   2 转：同上，但阳蛇那 5 发是穿透弹（穿透在子弹对象里判定）
var _q = [];
for (var i = 0; i < yy_shot_count_yin; i++)
{
    array_push(_q, { kind: 0, poison: (i == 0) });      // 每五发的第一发带毒
    if (yy_shot_count_yang > 0)
        array_push(_q, { kind: 1, poison: false });
}

yy_burst = _q;
yy_burst_gap = 0;

// 已经真的把这一轮吐出来了 → 起手标记必须清掉。
// 海克斯「疑神疑鬼」会让父对象直接空放 event_user(1)（obj_card_parent/Step_0:240-257），
// 那时起手倒计时可能还没走完；不清的话等起手到点会再排一轮，同一轮打两遍。
yy_charge = 0;

audio_play_sound(snd_shot, 0, 0);
