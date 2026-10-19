// 谛听钟：罩住美食，可被卡片攻击。被技能1钻出/技能3音波引信后 3 秒自毁并原地产生魂体开路鼠。
event_inherited();

ly_kind = "diting_prison";
ly_anims = longyuan_animation_table("diting_prison");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "birth";
ly_timer = 0;
ly_life = 0;
prison_col = -1;
prison_row = -1;

mouse_id = "";
hp = LY_DITING_PRISON_HP;
maxhp = LY_DITING_PRISON_HP;
move_speed = 0;
target_type = "normal";
can_use_ladder = false;
image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
state = ENEMY_STATE.ACTING;

longyuan_play("出生", true);
