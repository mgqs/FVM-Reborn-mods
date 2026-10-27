// 2026-10-27：威望格不需要逐帧判定（灰不灰在 Create 时按「本关有没有通关」定）
// 下面这段只服务旧的卡片奖励兜底
if (reward_kind == "" && target_card_id != ""){
	if is_card_unlocked(target_card_id){
		if get_card_info_simple(target_card_id).max_shape >= target_shape{
			dimmed = true
		}
	}
}
