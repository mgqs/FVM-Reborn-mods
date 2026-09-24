/// @desc 治愈喵 2转（全能治愈喵）：全屏即刻治疗 + 保留1转回血Buff
/// event_user(11) — 由Step事件在施法动画末尾触发

var _cfg = zhiyumiao_get_config();
var _heal_amount = _cfg.instantHeal;
var _total_applied = 0;
var _target_count = 0;

// 全屏：当前对局中所有有效友方卡片
with (obj_card_parent) {
    if (hp > 0) {
        // 阵亡卡片跳过，不治疗不复活
        var _applied = min(_heal_amount, max_hp - hp);
        if (_applied > 0) {
            hp += _applied;
            instance_create_depth(x, y + 30, depth - 4, obj_card_heal_effect);
        }
        _total_applied += _applied;
        _target_count++;

        // 保留1转回血Buff
        zhiyumiao_apply_regen_buff(other.id, id);
    }
}

// 全屏施法特效（使用通用治疗特效，放大表现）
var _full_effect = instance_create_depth(x, y - 10, depth - 4, obj_card_heal_effect);
_full_effect.image_xscale = 2.5;
_full_effect.image_yscale = 2.5;
