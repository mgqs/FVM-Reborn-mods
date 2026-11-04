// obj_mianbao_boom（融合菠萝面包 · 死亡爆炸）Step 事件
// ① 播爆炸段（death_first → death_last，每 flash_speed 帧换一张）
// ② 播到 hit_index（视觉炸开那帧）时才结算一次 5*5 灰烬爆炸，结算完继续把动画播完
if global.is_paused{
	exit
}

t++;
image_index = death_first + floor(t / flash_speed);

// ---------- 伤害：等到画面炸开那一帧再算（原来在卡片 Destroy 里立刻算，动画没走完老鼠就没了）----------
if (!hit_done && image_index >= hit_index){
	hit_done = true;

	// 只有 hp 归零才炸；非防爆鼠秒杀出灰烬，防爆鼠 / BOSS 只吃 900
	can_mouse_list_x = ["can_mouse"];
	with (obj_enemy_parent){
		if (hp > 0
			&& grid_row >= other.grid_row - 2 && grid_row <= other.grid_row + 2
			&& grid_col >= other.grid_col - 2 && grid_col <= other.grid_col + 2){
			if (array_get_index(other.can_mouse_list_x, mouse_id) != -1 && !can_dropped){
				into_act();
			}
			else if (is_boss || (immune_to_ash && hp > 900)){
				hp -= 900;
				event_user(0);
			}
			else{
				instance_create_depth(x, y - 20, depth, obj_mouse_ash_death);
				instance_destroy();
			}
		}
	}

	global.audio.play(snd_coke_bomb_explode, 0, false);
	if global.screen_shake{
		Camera_Shock(5, 20)
	}
}

if (image_index > death_last){
	instance_destroy();
}
