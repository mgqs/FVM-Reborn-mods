// 2026-10-27：魔塔奖励已改成威望 → 点击只弹提示，不再发奖
//   威望在通关结算（obj_battle_pause_manager/Step_2）里直接进背包，
//   这里如果还能「点一下给一次」就会重复发放
if (reward_kind != "" && !obj_tower_cake_bg.is_submenu_opened){
	if (dimmed) show_notice("首通威望已发放", 60);
	else       show_notice("通关后自动发放威望", 60);
	exit;
}

// 旧卡片奖励兜底（塔关已经不再有卡奖励）
if (!dimmed && target_card_id != "" && !obj_tower_cake_bg.is_submenu_opened){
	if (is_eternal_gacha_mode()) {
		show_notice("抽卡模式通过随机奖励获取卡片形态", 60);
		exit;
	}
	if is_card_unlocked(target_card_id){
		upgrade_card_shape(target_card_id,target_shape)
		global.audio.play(snd_button,0,0)
		show_notice("卡片转职已获取",60)
	}
	else{
		show_notice("该卡片未解锁，无法领取",60)
	}
}
