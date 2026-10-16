// obj_ronghesanxian_burn_fx（融合三线 · 燃烧挂身火焰）
// 纯表现对象：复用后羿的灼烧贴图 spr_houyi_god_fire_2，跟随目标老鼠、5 帧循环。
// 生命周期完全由控制器 obj_ronghesanxian_burn_ctrl 掌控（目标死亡/燃烧结束时由它销毁）。
follow = noone;
timer = 0;
image_speed = 0;
image_xscale = 1.8;
image_yscale = 1.8;
