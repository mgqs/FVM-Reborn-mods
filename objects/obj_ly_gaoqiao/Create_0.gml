event_inherited();

// ===== 高跷鼠：行为 1:1 仿照非主流鼠（obj_non_mainstream_mouse），仅外观精灵/动作为自己的 =====
hp = 660;
maxhp = 660;
move_speed = 0.9;
atk = 10;
atk_cycle = 42;
move_anim = 8;        // 移动帧数（与动画表一致，仅用于父类内部计数）
attack_anim = 7;      // 啃咬帧数
death_anim = 13;      // 死亡帧数
target_type = "dance"; // 平时为舞步形态（仅穿透/旋转/火龙果可命中），啃咬时切 normal
mouse_id = "longyuan_gaoqiao";
sprite_index = spr_gaoqiao;
can_use_ladder = false;

// 舞步闪避（对齐非主流鼠 dance_cooldown）
dance_cooldown = 0;
ly_dodge_start = 0;    // 本次闪避动作在 spr_gaoqiao 中的起始 image_index
ly_retreat = false;    // 遇高架物后退中
ly_obstacle_near = false;

// 东风鼠扇风生效时，高跷鼠（舞步形态）移动速度同样 ×2（基类据此给加速乘区）
ly_air_speed_bonus = true;

// 高架物：前方 2 格内遇到这些高架卡片（或连通的米线桥）时先后退（保留既有专属逻辑）
ly_high_obstacle_ids = ["mixian", "chocolate_bread", "pineapple_explosive_bread", "lightning_baguette"];

// 自己的 SWF 动作帧区间（全部在单一精灵 spr_gaoqiao 内）
ly_anims = longyuan_animation_table("gaoqiao");
// 取某动作的 [0-based 起始 image_index, 帧数]
ly_clip_range = function(_action) {
    var _c = ly_anims[$ _action];
    return [_c[1] - 1, _c[2] - _c[1] + 1];
};

state = ENEMY_STATE.NORMAL;
