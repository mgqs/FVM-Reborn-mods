// obj_ronghehuopen_ice_ctrl（融合火盆·冰弹逻辑控制器）Create 事件
// 只管灵融「冰火弹」（brazier_list 哨兵 -9999）的运行时逻辑：命中减速 / 碎冰死亡 / 冰冻命中特效。
//   换贴图不归这里 —— obj_bullet_parent 的 Begin Draw 调 bullet_hazard_look() 在绘制前统一做，
//   所以控制器不在场（或卡片被铲掉）也不会闪回普通火弹。
// 为什么还要独立控制器：上面那几件事都要「每帧扫附近的敌人」，
//   挂不到融盆卡片上（卡片铲掉后冰弹还在飞）。
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
