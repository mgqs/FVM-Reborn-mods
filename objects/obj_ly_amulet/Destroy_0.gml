// 只清本体记录的飞行符咒引用；本体无敌由 obj_ly_fuzhou 每步按符咒/魂鼠存活情况重算，
// 因此符咒转化为魂鼠（本 Destroy 触发）时不会错误地解除无敌。
if (instance_exists(owner)) owner.ly_amulet = noone;
