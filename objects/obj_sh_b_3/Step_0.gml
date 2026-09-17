if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

// 生命周期结束自毁（spr_sh_b_3 有 11 帧，给稍长一点的时间）
if (timer >= 60)
    instance_destroy();
