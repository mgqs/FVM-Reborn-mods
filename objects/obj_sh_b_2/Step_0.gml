if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / 5);

// 生命周期结束自毁
if (timer >= 50)
    instance_destroy();
