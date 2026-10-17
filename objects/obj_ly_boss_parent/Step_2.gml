// 继承 obj_enemy_parent 的难度血量缩放（hp_modified）与岩浆/黏液处理
event_inherited();

// BOSS 不适用的状态计时清零
frozen_timer = 0;
stun_timer = 0;
scare_timer = 0;
y_move = 0;
