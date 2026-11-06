// obj_zhuanzhuanji（转转鸡 / 五彩转转鸡 / 王室转转鸡）Create 事件
// 喷壶类·旋转喷壶类（照融合旋转咖啡壶）：每轮对 5×5 范围内敌人结算，**一轮总伤害 = atk**
//   0/1 转每圈结算 2 次；1 转起结算次数 ×2（每次减半，总量不变）；2 转范围内伤害 ×1.2
// 素材 24 帧：待机 0~10（编辑器 1~11 帧）、旋转 11~22（编辑器 12~23 帧）
//   🔴 2026-11-06 用户口径：**21 帧（index 20）转完一圈**，所以一轮旋转的主体是 11~20 这 10 帧，
//      21~22 只是烟圈消散的收尾，转完一圈后才回待机。
// 数值：atk（17 档）、攻击间隔 cycle（技能 9 档）
event_inherited();
plant_id = "zhuanzhuanji";
obj_type = object_index;
event_user(0);

if (shape == 0)      sprite_index = spr_zhuanzhuanji;
else if (shape == 1) sprite_index = spr_zhuanzhuanji_1;
else                 sprite_index = spr_zhuanzhuanji_2;

plant_type = "normal";
feature_type = "normal";
target_type = "rotate";
is_slowdown = false;
image_speed = 0;

flash_speed = 5;       // 待机帧速
SEG_IDLE_LEN  = 11;    // 待机 0~10（编辑器 1~11 帧）
SEG_ATK_FIRST = 11;    // 旋转段起点（编辑器 12 帧）
SPIN_LEN      = 10;    // 11~20 = 正好转满一圈（编辑器第 21 帧满圈）
SEG_ATK_LEN   = 12;    // 11~22（后两帧是烟圈消散的收尾）
atk_flash_speed = 2;

idle_anim   = SEG_IDLE_LEN - 1;    // 父对象兜底：待机 0~10
attack_anim = SEG_ATK_LEN;         // 父对象兜底：11~22

// 结算次数：0 转 2 次；1·2 转 4 次（双发）→ 每次伤害按份数均分，一轮总量恒 = atk
hit_count = (shape >= 1) ? 4 : 2;
K = hit_count;
HIT_FRAMES = [];
for (var _i = 0; _i < hit_count; _i++){
    array_push(HIT_FRAMES, floor((_i + 1) * SPIN_LEN / (hit_count + 1)));
}

range_mult = (shape >= 2) ? 1.2 : 1.0;
range_col = 2;
range_row = 2;

idle_t = 0;
atk_t = -1;
hit_idx = 0;
atk_timer = 0;
// 攻击间隔不再写死：Step 里直接读注册表 cycle（技能 9 档在 mod_skill_init）

// 可打名单：rotate 全套（陆 / 空 / 非主流 / 障碍 / 地鼠军 / 幽灵）**再加潜水鼠**
//   （2026-11-06 用户口径：转转鸡要能打潜水；rotate 本身不含 diver，所以卡片侧补一支）
zzj_can_hit = function(_t){
    return can_hit(target_type, _t) || _t == "diver";
};
