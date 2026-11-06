// obj_caihongshe 发射巧克力糖豆（event_user(1)）
// 2026-11-06 用户口径：2 转「子弹数量 +2」= **同一方向连射 3 发、中间错帧**，不是三向散射。
//   （旧写法把每发 y 上错 12px、vy 逐发 -0.4，看着像三向散射 —— 那是和别的卡混了）
// 这里只打**第 1 发**，剩下的由 Step 的 burst_left / burst_timer 错帧补发：
//   发射点 / 方向 / 伤害完全一样，只是晚几帧出膛，和其它卡的「加子弹」同一套做法。
cai_fire_one();

burst_left  = max(0, shot_count - 1);
burst_timer = 0;

global.audio.play(snd_shot, 0, 0);
