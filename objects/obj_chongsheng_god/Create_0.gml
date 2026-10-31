event_inherited();
plant_id = "chongsheng_god";
obj_type = object_index;
event_user(0);

if (shape == 0)
    sprite_index = spr_chongsheng_god;
else if (shape == 1)
    sprite_index = spr_chongsheng_god_1;
else if (shape == 2)
    sprite_index = spr_chongsheng_god_2;
else if (shape == 3)
    sprite_index = spr_chongsheng_god_3;

flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
image_speed = 0;

// 帧布局（2026-10-28 用户）：1-12 待机 / 13-34 攻击，第 20 帧触发复活波
idle_anim = 11;
attack_anim = 22;
chongsheng_trigger_frame = 19;      // 第 20 帧（0 起算）
chongsheng_end_frame = 33;          // 第 34 帧（攻击末帧，播完自毁）

revive_count = 0;
revive_triggered = false;
buff_applied = false;

grid_range_col = 2;
grid_range_row = 2;
if (shape == 3) {
    grid_range_col = 3;
    grid_range_row = 2;
}

revive_limit = 4;
if (shape == 1) revive_limit = 6;
else if (shape == 2) revive_limit = 6;
else if (shape == 3) revive_limit = 9;

// 默认值；真正的取值在 Step 触发复活时按当时的星级/技能重算（Create 阶段 skill 还可能是 0）
chongsheng_reduction = 0.3;
chongsheng_duration = cycle;        // 减伤BUFF持续（技能 15~20 秒）
chongsheng_invuln = cycle;          // 复活瞬间无敌时长（=攻击间隔，技能 2.5~3.5 秒）
invuln_pending = 0;

buff_duration = chongsheng_duration;

// 种下时释放 effect_2 特效
var _eff2_spr = spr_chongsheng_god_effect_0_2;
if (shape == 1) _eff2_spr = spr_chongsheng_god_effect_1_2;
else if (shape == 2) _eff2_spr = spr_chongsheng_god_effect_2_2;
else if (shape == 3) _eff2_spr = spr_chongsheng_god_effect_3_2;

var _eff2 = instance_create_depth(x, y, depth - 100, obj_card_heal_effect);
_eff2.sprite_index = _eff2_spr;
