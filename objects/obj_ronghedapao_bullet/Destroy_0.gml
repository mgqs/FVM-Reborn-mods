// obj_ronghedapao_bullet Destroy 事件：落地爆炸结算
// 判定改成「按格子」精判（原版是 point_distance < 250 的近似），
// 这样 0 转 3*3（3 行 × 3 列）、1/2 转 3*5（5 行 × 3 列）与情报岛写的范围一致。
// 落点固定在本行第 8 列（target_col = 7），3 列宽 = 第 7~9 列，正好贴住右边界。
var _row = target_row;
var _col = target_col;

with (obj_enemy_parent) {
	if (abs(grid_row - _row) <= other.blast_row_half
		&& abs(grid_col - _col) <= other.blast_col_half) {

		// 巧克力球：对特定鼠改为定身
		if (array_get_index(other.can_mouse_list, mouse_id) != -1 && !can_dropped) {
			into_act();
		}
		// 奶盖桥岩浆障碍物：不接受「碾压直接销毁」，只按 50% 血量结算
		else if (mouse_id == "longyuan_bridge_obstacle") {
			damage_amount = other.damage;
			damage_type = "ash";
			event_user(0)
		}
		else {
			// 防爆鼠 / BOSS：只吃一份伤害
			if (immune_to_ash && hp > other.damage) {
				damage_amount = other.damage;
				damage_type = "ash";
				event_user(0)
			}
			else if (other.crush_kill) {
				// 灵魂融合：爆炸属性改为碾压 —— 鼠军直接消失（不出灰烬），BOSS 除外
				if (is_boss) {
					damage_amount = other.damage;
					damage_type = "ash";
					event_user(0)
				}
				else {
					instance_destroy();
				}
			}
			else {
				// 灰烬：不防爆的直接烧成灰
				instance_create_depth(x, y - 20, depth, obj_mouse_ash_death)
				instance_destroy();
			}
		}
	}
}

// 傲慢龙柱的青苹果：灵魂融合大炮的碾压可直接秒杀（触发苹果的「消失」动画）
with (obj_longzhu_green_apple) {
	if (hp > 0 && abs(row - _row) <= other.blast_row_half && abs(col - _col) <= other.blast_col_half) {
		hp = 0;
	}
}
