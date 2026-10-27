// 无常拘魂锁链：罩住格子，可被卡片攻击。存在期间本格卡片不可铲除，且与本格卡片同种的卡槽冷却冻结。
event_inherited();

ly_kind = "wuchang_chain";
ly_anims = longyuan_animation_table("wuchang_chain");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "idle";
chain_col = -1;
chain_row = -1;
locked_cards = ds_list_create(); // 被本锁链禁止铲除的卡片（死亡时恢复）

mouse_id = "";
hp = LY_WUCHANG_CHAIN_HP;
maxhp = LY_WUCHANG_CHAIN_HP;
move_speed = 0;
target_type = "normal";
can_use_ladder = false;
immune_to_ash = true;
image_speed = 0;
state = ENEMY_STATE.ACTING;

longyuan_play("待机");
