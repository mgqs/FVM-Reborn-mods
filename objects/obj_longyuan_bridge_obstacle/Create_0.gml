event_inherited();

target_type = "obstacle";
mouse_id = "longyuan_bridge_obstacle";
hp = 80000;
maxhp = hp;
move_speed = 0;
can_use_ladder = false;
visible = true;
// 免疫碾压卡的「非免疫灰烬即秒杀」判定，让炸弹/碾压都走 Other_10 的固定 50% 扣血
immune_to_ash = true;
// 血量主控：卡片侧有的实现会先 hp -= atk 再 event_user(0)，
// 统一以 ly_hp_lock 为准（每次命中固定 -50%），避免被额外伤一口
ly_hp_lock = hp;

// 状态机：idel(出现 10s) → move(沿轨道) → dead(死亡动画)
zhangaiwu_state = "idel";
zhangaiwu_idle_timer = 0;

sprite_index = spr_zhangaiwu_idel;
image_speed = 0.15;
image_index = 0;

longyuan_bridge_track = "";
longyuan_bridge_path = [];
longyuan_bridge_path_index = 0;
longyuan_bridge_next_x = x;
longyuan_bridge_next_y = y;
longyuan_bridge_cells_cleared = [];
