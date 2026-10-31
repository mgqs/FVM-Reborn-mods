// 重生神出手后立即自毁，但减伤 BUFF 必须按自己的时长（技能 15~20 秒）走完，
// 不能跟着施法者一起消失 —— 否则「减伤时间 15~20 秒」永远只有半秒。
// 所以这里不再清空 chongsheng_buff_timer / chongsheng_buff_reduction，让计时器自然归零。
event_inherited();
