// 统一入口（2026-11-10）：火源 / 反弹源各自一个父对象，新卡只要 parent 指过去，子弹侧不用动
bullet_hazard_fire(id, other, other.atk * other.fire_mult_scale);
