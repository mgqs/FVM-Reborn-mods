// Begin Draw：所有 Step 都跑完、真正绘制之前的那一拍。
// 子弹自己的 Step 每帧会写 sprite_index（典型写法 `if (burnt == 1) sprite_index = spr_fire_bullet;`），
// 所以「熔炼外观」只能在这里覆盖；放 Step / End Step 都要再靠外部控制器每帧锁一次。
bullet_hazard_look(id);
