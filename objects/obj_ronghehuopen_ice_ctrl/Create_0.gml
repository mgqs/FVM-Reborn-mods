// obj_ronghehuopen_ice_ctrl（融合火盆·二转冰弹控制器）Create 事件
// 为什么需要独立控制器：冰弹的「贴图锁定 / 命中减速 / 命中特效」不能挂在融盆卡片上 ——
// 卡片被铲掉后冰弹会被自己的 Step 改回火弹贴图（子弹 Step 里有 `if (burnt == 1) sprite_index = spr_fire_bullet;`）。
// 卡片只要点燃过冰弹就确保本控制器存在（见 obj_ronghehuopen/Step_0.gml），场上不再有冰弹时自行销毁。
idle_frames = 0

// 本帧 Begin Step 记录的冰弹坐标：命中当帧子弹就会被对象池回收，End Step 已经取不到它，
// 所以「命中特效配对」要用这份记录（见 Step_1 / Step_2）
rec_x = [];
rec_y = [];
