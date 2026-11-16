// 火源类卡片的公共父对象（2026-11-10）：子弹侧只认它，新火盆只要 parent 指向这里，不用再改子弹
hazard_role = "fire";
fire_mult_scale = 1;   // 过火倍率 = atk * 这个；倍率类卡（能量喵）atk 置 0、倍率放 fire_mult_override，仍乘这个
event_inherited();
