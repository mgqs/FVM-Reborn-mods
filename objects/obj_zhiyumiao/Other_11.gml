/// @desc 治愈喵 0转/1转：5x5范围即刻治疗 + 玩家角色治疗 + 1转附带回血Buff
/// event_user(1) — 由Step事件在施法动画末尾触发

var _cfg = zhiyumiao_get_config();
var _heal_amount = zhiyumiao_get_heal_amount(shape);
var _radius = zhiyumiao_get_range_radius(shape);
var _apply_regen = zhiyumiao_has_regen(shape);
var _total_applied = 0;
var _target_count = 0;

// 治疗5x5范围内的友方卡片
with (obj_card_parent) {
    if (object_index == obj_player_character) continue;
    if (hp > 0 && abs(grid_col - other.grid_col) <= _radius && abs(grid_row - other.grid_row) <= _radius) {
        // 阵亡卡片跳过，不治疗不复活
        var _applied = min(_heal_amount, max_hp - hp);
        if (_applied > 0) {
            hp += _applied;
            instance_create_depth(x, y + 30, depth - 4, obj_card_heal_effect);
        }
        _total_applied += _applied;
        _target_count++;

        // 1转及以上：施加3秒回血Buff（同源刷新，不叠层）
        if (_apply_regen) {
            zhiyumiao_apply_regen_buff(other.id, id, other.shape);
        }
    }
}

// 治疗玩家角色
var _player_healed = zhiyumiao_heal_player(_heal_amount);
_total_applied += _player_healed;

// 1转及以上：给玩家角色也施加回血Buff
if (_apply_regen && instance_exists(obj_player_character)) {
    zhiyumiao_apply_regen_buff(id, obj_player_character.id, shape);
}

// 施法特效（使用通用治疗特效）
instance_create_depth(x, y - 10, depth - 4, obj_card_heal_effect);
