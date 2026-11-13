/// 金刚马 命中迸裂：6 帧各 3 帧（共 18 帧）后自毁
if (global.is_paused){
    exit;
}

timer++;
image_index = floor(timer / 3);

if (timer >= 18){
    instance_destroy();
}
