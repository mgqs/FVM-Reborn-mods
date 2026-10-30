// 2026-10-27：魔塔奖励已改成威望 → 点击只弹提示，不再发奖
//   威望在通关结算（obj_battle_pause_manager/Step_2）里直接进背包，
//   这里如果还能「点一下给一次」就会重复发放
if (reward_kind != "" && !obj_tower_cake_bg.is_submenu_opened){
	if (dimmed) show_notice("首通威望已发放", 60);
	else       show_notice("通关后自动发放威望", 60);
	exit;
}
