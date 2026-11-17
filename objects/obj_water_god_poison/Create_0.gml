/// 水神 反弹毒伤（挂在被毒到的老鼠身上）Create 事件
/// 由 scripts/mod_bullet_hazard 的 water_god_poison_apply() 创建，并由它负责「只刷新不叠加」。
/// 每 tick_frames（60 = 1 秒）结算一跳，共 ticks（3）跳；鼠身紫雾只是表现，不进判定。
target      = noone;
dmg         = 0;
ticks       = 3;
tick_frames = 60;
t           = 0;
done        = 0;

visible = false;
image_speed = 0;
