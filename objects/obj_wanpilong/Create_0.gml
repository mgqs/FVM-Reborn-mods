/// @description 顽皮龙 - 创建事件
event_inherited();
plant_id = "wanpilong";
obj_type = object_index;
event_user(0);

// 精灵设置
sprite_index = spr_wanpilong;
if (shape == 1)
    sprite_index = spr_wanpilong_1;
else if (shape == 2)
    sprite_index = spr_wanpilong_2;

attack_anim = 0;
idle_anim = sprite_get_number(sprite_index);
image_speed = 0;
flash_speed = 5;
plant_type = "normal";
is_slowdown = false;
current_hp = hp;
can_shovel_remove = true;
invincible = false;

// ============================================
// 顽皮龙专属配置
// ============================================

// 转职形态能力
// 0转: 5x5范围移动卡片
// 1转: 全屏范围移动卡片
// 2转: 全屏范围移动卡片+角色
can_move_character = (shape >= 2);
is_fullscreen_range = (shape >= 1);

// 前摇时间（毫秒转帧，flash_speed约等于帧率基准）
// 3.1秒 = 3100ms，按60fps约186帧
pre_swing_frames = 3100 / (1000 / 60); // 约186帧

// 状态机枚举
enum WANPILONG_STATE
{
    IDLE,              // 空闲待机
    TARGETING_SOURCE,   // 第一段：选择源目标
    SOURCE_CONFIRMED,   // 源目标已确认
    PRE_SWING,         // 前摇中
    TARGETING_DEST,     // 第二段：选择目标格
    RESOLVING,         // 结算中
    COOLDOWN,          // 冷却中
    FADING_OUT         // 淡出销毁
}

// 当前状态
wanpilong_state = WANPILONG_STATE.IDLE;

// 选中的源目标
source_entity = noone;
source_entity_grid_col = -1;
source_entity_grid_row = -1;
source_is_character = false;

// 目标位置
dest_grid_col = -1;
dest_grid_row = -1;

// 前摇计时器
pre_swing_timer = 0;

// 冷却相关
cooldown_timer = 0;
cooldown_total = 0;

// 技能释放标识（确保一次释放只结算一次）
cast_resolved = false;
cast_cancelled = false;

// 耗能（配置值）
wanpilong_cost = 100;

// 范围半径（切比雪夫距离）
// 5x5 = 半径2（dx<=2 && dy<=2）
range_radius = 2;

// 可被移动的标记（默认所有卡片都可以被移动，除非特殊标记）
// canBeMovedByWanpilong 默认 true
can_be_moved_by_wanpilong = true;

// 淡出计时器
fade_out_timer = 0;

// 显示用：范围高亮网格
highlight_cells = ds_list_create();
