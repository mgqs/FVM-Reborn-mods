// 用户事件1 - 全屏植物回满HP + 特效
with (obj_card_parent) {
    if (hp > 0) {
        if (hp < max_hp) {
            hp = max_hp;
        }
        var effect = instance_create_depth(x, y, depth - 4, obj_12yinliao_effect);
        effect.is_one_shot = true;
    }
}
