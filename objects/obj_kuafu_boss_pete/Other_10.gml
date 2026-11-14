// 变异护盾（判定抄牡蛎鼠 Other_10）：展开期间非投掷卡片（damage_type != "throw"）减伤 50%，
// 投掷类卡片（糖炒栗子/生煎锅/巧克力炮等 "throw" 系）照常全额。
// 先按比例缩减 damage_amount，再走父类受击流程（海克斯/测试关/flash/shield_hp 全保留）。
if (shield_active && damage_type != "throw"){
	damage_amount = damage_amount * shield_take_mult
}
event_inherited()
