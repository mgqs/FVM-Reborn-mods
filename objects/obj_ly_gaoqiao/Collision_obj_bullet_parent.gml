// 触发条件与非主流鼠完全一致：攻击中/舞步中/死亡/后撤中不触发，闪避冷却中不触发。
if (state != ENEMY_STATE.ATTACK && state != ENEMY_STATE.ACTING && state != ENEMY_STATE.DEAD
    && state != ENEMY_STATE.IDLE && dance_cooldown <= 0 && hp > 0 && !ly_retreat) {
    timer = 0;
    state = ENEMY_STATE.ACTING;
    // 高跷自己的舞步：精灵第11-30帧（0-based 10-29）共20帧；外观按触发当帧血量取正常/破损起点
    ly_dodge_start = (hp <= maxhp * hurt_rate) ? LY_GAOQIAO_DANCE_HURT_START : LY_GAOQIAO_DANCE_START;
}
