// Step：不继承父类（不移动、不啃卡片、不触发游戏结束）
if (global.is_paused) exit;

// 载体或绑定目标失效（含傀儡马进入死亡流程）则自毁
if (!instance_exists(decoy_card) || decoy_card.plant_id != "kuileima"
    || decoy_card.zodiac_dying
    || !instance_exists(decoy_target) || decoy_target.hp <= 0) {
    instance_destroy();
    exit;
}

// 镜像绑定老鼠的身份/血量/体型，保证比例伤害与斩杀伤害结算一致
decoy_sync_identity(decoy_target);
sprite_index = decoy_target.sprite_index;
image_index = decoy_target.image_index;
image_xscale = decoy_target.image_xscale;
image_yscale = decoy_target.image_yscale;
image_angle = decoy_target.image_angle;

// 攻击卡片通过全局类型索引寻找敌人，代理必须像真实老鼠一样注册。
if (!enemy_registered || enemy_registered_type != target_type) {
    if (enemy_registered && variable_global_exists("enemy_by_type")
        && variable_struct_exists(global.enemy_by_type, enemy_registered_type)) {
        var _old_list = global.enemy_by_type[$ enemy_registered_type];
        var _old_idx = array_get_index(_old_list, id);
        if (_old_idx != -1) array_delete(_old_list, _old_idx, 1);
    }
    if (!variable_global_exists("enemy_by_type")) global.enemy_by_type = {};
    if (!variable_struct_exists(global.enemy_by_type, target_type)) global.enemy_by_type[$ target_type] = [];
    array_push(global.enemy_by_type[$ target_type], id);
    enemy_registered = true;
    enemy_registered_type = target_type;
}

// 吸附在傀儡马所在格（攻击判定按grid行列与距离）
x = decoy_card.x;
y = decoy_card.y;
grid_col = decoy_card.grid_col;
grid_row = decoy_card.grid_row;
depth = decoy_card.depth;

// 清除一切控制/位移状态
state = ENEMY_STATE.NORMAL;
ice_timer = 0;
frozen_timer = 0;
scare_timer = 0;
stun_timer = 0;
is_frozen = false;
is_slowdown = false;
is_scare = false;
is_stun = false;
image_alpha = 0;
flash_value = 0;
