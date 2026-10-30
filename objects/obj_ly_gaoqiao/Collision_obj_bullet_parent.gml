// 触发条件：
// 1) 状态守卫：攻击中/舞步中/死亡/后撤中不触发
// 2) 冷却守卫：dance_cooldown > 0 不触发
// 3) 子弹 target_type 守卫：dance 形态只被 pierce/rotate/d_fruit 三种子弹命中（can_target_on 明确定义），
//    普通子弹（normal）虽然物理碰撞能触发但实际上根本打不中 dance，不应该触发闪避浪费动画帧
// 子弹侧缺 target_type 时会直接崩「Variable obj_xxx.target_type not set before reading it」
// （已实证：obj_ice_god_bullet 这类老子弹没定义）。这里按普通弹兜底，只影响舞步守卫的判定。
var _bullet_target_type = variable_instance_exists(other, "target_type") ? other.target_type : "normal";

if (state != ENEMY_STATE.ATTACK && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DEAD
    && state != ENEMY_STATE.IDLE && dance_cooldown <= 0 && hp > 0 && !ly_retreat
    && can_target_on(_bullet_target_type, target_type)) {
    timer = 0;
    state = ENEMY_STATE.ACTING;
    // 高跷自己的舞步：随机选 3 段闪避精灵（各独立文件，一次性播完后回 NORMAL）
    longyuan_play(choose("闪避A", "闪避B", "闪避C"), true);
}
