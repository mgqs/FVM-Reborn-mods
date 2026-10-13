if global.is_paused {
    image_speed = 0
    exit;
} else {
    image_speed = 0.75
}

// 检查父卡片是否存在
if !instance_exists(parent_card) {
    instance_destroy();
    exit;
}

// 保存父卡片id，供with内部使用
var _parent_card = parent_card;

// 检查场上同类卡片数量
var same_count = 1;
with (obj_guangming_god) {
    if (id != _parent_card && shape >= 2) {
        same_count++;
    }
}

// 数量不足2时，特效消失
if same_count <= 1 {
    instance_destroy();
}
