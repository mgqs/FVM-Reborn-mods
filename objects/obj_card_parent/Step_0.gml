// obj_plant_parent 的 Step 事件
if global.is_paused{
	exit
}
if ice_timer > 0{
	ice_timer--
	is_slowdown = true
}
else{
	is_slowdown = false
}
if frozen_timer > 0{
	frozen_timer--
	is_frozen = true
}
else{
	is_frozen = false
}
// 重生神复活瞬间的无敌：整帧回血（挡致命伤），先于减伤结算
if chongsheng_invuln_timer > 0 {
	chongsheng_invuln_timer--
	if hp < _prev_hp {
		hp = _prev_hp
		if hp > max_hp hp = max_hp
	}
}
if chongsheng_buff_timer > 0 {
	chongsheng_buff_timer--
	if hp < _prev_hp && chongsheng_buff_reduction > 0 {
		var _dmg = _prev_hp - hp
		var _reduced = round(_dmg * chongsheng_buff_reduction)
		hp += _reduced
		if hp > max_hp hp = max_hp
	}
}

if (longyuan_webbed && longyuan_web_shield_hp > 0 && hp < _prev_hp) {
	var _web_damage = _prev_hp - hp;
	var _web_absorbed = min(_web_damage, longyuan_web_shield_hp);
	hp += _web_absorbed;
	longyuan_web_shield_hp -= _web_absorbed;
	if (longyuan_web_shield_hp <= 0) {
		longyuan_webbed = false;
		if (longyuan_webbed_sprite != -1) sprite_index = longyuan_webbed_sprite;
		if (state == CARD_STATE.SLEEP) state = CARD_STATE.IDLE;
	}
}
_prev_hp = hp
if (variable_instance_exists(id,"zodiac_guard_time") && zodiac_guard_time > 0) {
    zodiac_guard_time--;
    if (hp < zodiac_guard_hp) {
        hp = zodiac_guard_hp;
        zodiac_guard_hits--;
        if (zodiac_guard_hits <= 0) zodiac_guard_time = 0;
    }
    zodiac_guard_hp = hp;
}
if hp <= 0{
	instance_destroy()
}

if flash_value >0{
	
	flash_value -= 10
	
}
if awake_buff_timer > 0{
	awake_buff_timer--
	if state == CARD_STATE.SLEEP{
		if awake_anim > 0{
			state = CARD_STATE.AWAKE
		}
		else{
			state = CARD_STATE.IDLE
		}
	}
}

// ---------- 常驻状态标记 ----------
// 龙柱的「清醒」（松露大厅封印柱）与「保护」（百味关封印柱）原来只在施法瞬间播一次
// 约 1 秒的 spr_mixian_effect2，但效果本身持续 15~30 秒，看着像「没生效」。
// 这里按卡片身上的实际计时维持常驻标记：计时 > 0 就显示，归零立刻消失，
// 做到「龙柱效果持续几秒就显示几秒」。
if (!variable_instance_exists(id, "awake_mark_obj")) {
	awake_mark_obj = noone;
	guard_mark_obj = noone;
}
if (hp > 0 && variable_instance_exists(id, "plant_id") && plant_id != "player") {
	// 清醒：awake_buff_timer 期间不可被催眠
	if (awake_buff_timer > 0) {
		if (!instance_exists(awake_mark_obj)) {
			awake_mark_obj = instance_create_depth(x + 34, y - 62, depth - 40, obj_card_buff_mark);
			awake_mark_obj.mark_owner = id;
			awake_mark_obj.mark_kind = 0;
			awake_mark_obj.sprite_index = spr_mixian_effect2;
			awake_mark_obj.mark_off_x = 34;
			awake_mark_obj.mark_off_y = -62;
			awake_mark_obj.mark_rate = 6;
			awake_mark_obj.mark_base_alpha = 1;
			awake_mark_obj.mark_pulse = 0;
			awake_mark_obj.image_xscale = 1.6;
			awake_mark_obj.image_yscale = 1.6;
		}
	}
	else if (instance_exists(awake_mark_obj)) {
		instance_destroy(awake_mark_obj);
		awake_mark_obj = noone;
	}

	// 保护：zodiac_guard_time 期间抵挡若干次伤害（含致命伤）
	if (variable_instance_exists(id, "zodiac_guard_time") && zodiac_guard_time > 0) {
		if (!instance_exists(guard_mark_obj)) {
			guard_mark_obj = instance_create_depth(x, y, depth - 41, obj_card_buff_mark);
			guard_mark_obj.mark_owner = id;
			guard_mark_obj.mark_kind = 1;
			guard_mark_obj.sprite_index = spr_xingqiongma_effect1;
			guard_mark_obj.mark_off_x = 0;
			guard_mark_obj.mark_off_y = 0;
			guard_mark_obj.mark_rate = 6;
			guard_mark_obj.mark_base_alpha = 0.7;
			guard_mark_obj.mark_pulse = 0.12;
			guard_mark_obj.image_xscale = 1.0;
			guard_mark_obj.image_yscale = 1.0;
		}
	}
	else if (instance_exists(guard_mark_obj)) {
		instance_destroy(guard_mark_obj);
		guard_mark_obj = noone;
	}
}
if state == CARD_STATE.SLEEP && !instance_exists(banding_sleep_obj) && awake_anim == 0{
	banding_sleep_obj = instance_create_depth(x-15,y-20,depth-1,obj_sleep_effect)
	banding_sleep_obj.banding_card_obj = id
}
if instance_exists(banding_sleep_obj){
	banding_sleep_obj.x = x-15
	banding_sleep_obj.y = y-20
	banding_sleep_obj.depth = depth-1
}
if state != CARD_STATE.SLEEP && instance_exists(banding_sleep_obj){
	instance_destroy(banding_sleep_obj)
}

// 计算深度值
//var depth_value = -((y + depth_offset) * 10 + x);
//depth = depth_value - depth_group * 100;



// 2026-11-08：原来这里调 get_grid_position_from_world(x,y)，运行时偶发
//   「argument0 not set」崩错（糖炒栗子踩到）。同算法内联，等价且不再依赖脚本调用。
var grid_pos = {
    col: floor((x - global.grid_offset_x) / global.grid_cell_size_x),
    row: floor((y - global.grid_offset_y) / global.grid_cell_size_y)
}

if !(variable_instance_exists(id, "platform_grid_lock") && platform_grid_lock) {
    grid_col = clamp(grid_pos.col, 0, global.grid_cols - 1)
    grid_row = clamp(grid_pos.row, 0, global.grid_rows - 1)
}

depth = calculate_plant_depth(grid_pos.col, grid_pos.row, plant_type)
if instance_exists(banding_star_obj){
banding_star_obj.depth = depth - 1
}

var water_define_pos_y = clamp(grid_col,0,global.grid_cols - 1)
var water_define_pos_x = clamp(grid_row,0,global.grid_rows - 1)

if !instance_exists(banding_water_obj) && global.grid_terrains[water_define_pos_x][water_define_pos_y].type == "water" {
	if plant_type == "lilypad" || (feature_type == "water" && plant_type == "normal"){
		banding_water_obj = instance_create_depth(x,y,depth+5,obj_in_water_effect)
		banding_water_obj.banding_card_obj = id
	}
}
if instance_exists(banding_water_obj) && global.grid_terrains[water_define_pos_x][water_define_pos_y].type != "water"{
	instance_destroy(banding_water_obj)
}

if is_frozen{
	exit
}
// 海克斯「疑神疑鬼」：攻击类美食（含人物）从放下的那一刻起就不停火。
// 原来是「场上没有鼠军时才强制 ATTACK」，等于只在空场才空放；玩家要的是常驻空放
if (hex_enabled() && state != CARD_STATE.SLEEP && hex_b3_no_stop_attack()
    && (plant_id == "player" || hex_b3_attack_major(plant_id))) {
    state = CARD_STATE.ATTACK;
}
// 海克斯「疑神疑鬼」：空场也要真的打出子弹，而不只是摆动作。
// 每张卡的出弹逻辑都写在自己的 Step 里、并且大多被 `if (has_enemy)` 包着：
// 场上没老鼠时它们连 event_user(1) 都走不到，父对象这边只改了 state，
// 于是玩家看到的就是「一直在做攻击动作，但一颗子弹也没有」。
// 这里由父对象接管空放：没有可打目标时按自己的 cycle 调一次发射事件（Other_11）。
if (hex_enabled() && hex_b3_no_stop_attack() && state != CARD_STATE.SLEEP
    && (plant_id == "player" || hex_b3_attack_major(plant_id))) {
    if (!variable_instance_exists(id, "b3_blank_cd"))      b3_blank_cd = 0;
    if (!variable_instance_exists(id, "b3_blank_allowed")) b3_blank_allowed = true;
    if (b3_blank_allowed) {
        var _hex_has_target = false;
        // 这里 with 是「卡片自己发起」的，所以 other = 这张卡、不带 other. 的 target_type = 老鼠的：
        // can_target_on(卡的 target_type, 鼠的 target_type) 正好是正确顺序
        with (obj_enemy_parent) {
            if (can_target_on(other.target_type, target_type)) {
                _hex_has_target = true;
                break;
            }
        }
        if (_hex_has_target) {
            // 有真目标就交给卡片自己打，别抢
            b3_blank_cd = max(1, cycle);
        } else if (b3_blank_cd > 0) {
            b3_blank_cd -= 1;
        } else {
            b3_blank_cd = max(1, cycle);
            if (variable_instance_exists(id, "target_enemy")) target_enemy = noone;
            try {
                event_user(1);
            } catch (_hex_blank_err) {
                // 少数卡的发射事件强依赖真实目标（直接读 target_enemy 的字段），
                // 空放会抛异常 —— 这种卡就关掉空放，避免每个攻击周期刷一次报错
                b3_blank_allowed = false;
            }
        }
    }
}
// 动画计时器
var current_flash_speed = flash_speed
if is_slowdown{
	current_flash_speed *= 2
}
// 减速：只在这一帧「状态发生变化」时改 cycle。
// 原来这里每帧无条件 cycle = origin_cycle，会把 obj_mod_battle_manager
// 和词条算好的攻速整个覆盖掉（「派送箱」这类攻速词条因此全部不生效）。
if (!variable_instance_exists(id, "b3_slow_prev")) b3_slow_prev = is_slowdown;
if (is_slowdown != b3_slow_prev) {
    b3_slow_prev = is_slowdown;
    if (is_slowdown) {
        cycle = (variable_instance_exists(id, "base_cycle") ? base_cycle : origin_cycle) * 2;
    } else if (variable_global_exists("buff_apply_id")) {
        // 解除减速：让管理器按「基准 × 词条倍率」重算一遍，别在这里硬写 origin_cycle
        global.buff_apply_id += 1;
    }
}
if timer < current_flash_speed - 1 {
    timer++;
} else {
    switch (state) {
        case CARD_STATE.IDLE:
            if image_index < idle_anim image_index++;
            else image_index = 0;
            break;
            
        case CARD_STATE.ATTACK:
            if (image_index >= (idle_anim+1) && image_index <= (idle_anim) + attack_anim) image_index++;
            else image_index = (idle_anim+1);
            break;
		
    }
    timer = 0;
}
