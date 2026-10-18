// obj_ronghehuopen_ice_ctrl（融合火盆·二转冰弹控制器）Create 事件
// 为什么需要独立控制器：冰弹的「贴图锁定 / 命中减速 / 命中特效」不能挂在融盆卡片上 ——
// 卡片被铲掉后冰弹会被自己的 Step 改回火弹贴图（子弹 Step 里有 `if (burnt == 1) sprite_index = spr_fire_bullet;`）。
// 卡片只要点燃过冰弹就确保本控制器存在（见 obj_ronghehuopen/Step_0.gml），场上不再有冰弹时自行销毁。
idle_frames = 0

// 本帧 Begin Step 记录的冰弹坐标：命中当帧子弹就会被对象池回收，End Step 已经取不到它，
// 所以「命中特效配对」要用这份记录（见 Step_1 / Step_2）
rec_x = [];
rec_y = [];

// 本帧 Begin Step 记录的「被冰弹压住」的敌人快照：[id, x, y, depth, hp, object_index]
// End Step 用它判断这一帧有没有被冰弹直接打死 → 播冰桶的碎冰死亡（见 Step_1 / Step_2）
rec_enemy = [];

// 冰弹「直接打死」的表现：冰桶二转的碎冰死亡动画（spr_mouse_ice_death，15 帧，整只老鼠裂开碎成冰块）
kill_probe = 48;        // Begin Step 记击杀目标的探测外扩（子弹 8~40px/帧，够覆盖一帧位移）
kill_fx_ofs_spr = 12;   // 碎冰鼠上移量（**精灵像素**，实际 = 12 × 敌人 |image_yscale|，1.8 倍时 ≈ 21.6px）
                        // 敌人精灵的「脚底」普遍在原点上方约 12px，而 spr_mouse_ice_death 的内容底边只在原点上方 2px，
                        // 不对齐就会整体下沉 20px 左右（表现为「老鼠突然消失、碎冰冒在别处」）。
