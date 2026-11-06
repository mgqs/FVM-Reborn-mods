flash_value = 150
hurt_time = 600
// 海克斯二期「悬丝的傀儡」：人物致死免疫 + 30 秒无敌。
// 人物是 obj_card_parent 的子对象，但这里没有 event_inherited()，
// 父对象 Other_12 里那句 hex_b3_card_lethal(id) 永远执行不到 —— 锁血词条因此完全没反应。
if (hex_enabled()) hex_b3_card_lethal(id);