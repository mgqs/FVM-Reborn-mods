// 哼哈·美食灵体：5000 基础血、减伤 80%。被牛头吸收后向第 9 列移动，进入第 9 列自消散并返还剩余血量。
event_inherited();

ly_kind = "hengha_food_spirit";
ly_anims = longyuan_animation_table("hengha_food_spirit");
ly_action = "";
ly_frame = 0;
ly_done = false;
ly_once = false;
ly_hit = false;
ly_mode = "birth";

mouse_id = "";
hp = LY_HENGHA_SPIRIT_HP;
maxhp = LY_HENGHA_SPIRIT_HP;
move_speed = 2.5;       // 占位：被吸向第 9 列的移动速度
atk = 0; atk_cycle = 60;
target_type = "normal";
can_use_ladder = false;
image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
state = ENEMY_STATE.ACTING;

ly_absorbing = false;
ly_absorb_boss = noone;

longyuan_play("出生", true);
