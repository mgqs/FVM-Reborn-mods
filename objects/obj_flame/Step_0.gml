// STEP 事件
if global.is_paused{
	x -= hspeed
	y -= vspeed
	vspeed -= gravity
	exit
}

// 烈火虎储能：场上所有火焰生成时按 value 比例充能（每火焰仅充一次）
if (!storage_charged) {
	storage_charged = true;
	with (obj_liehuohu) {
		liehuohu_storage_deposit(id, round(other.value * storage_ratio / 100));
	}
}

if !is_capture{
	// 只在落地后开始消失计时
	if (is_landed && !is_collected) {
	    if (disappear_timer < lifespan) {
	        disappear_timer++;
	    } else if (disappear_timer < lifespan + fade_duration) {
	        image_alpha = 1 - ((disappear_timer - lifespan) / fade_duration);
	        disappear_timer++;
	    } else {
	        instance_destroy();
	    }
	}

	// 物理运动（仅在未落地时）
	if (!is_landed) {
	    // 应用重力（仅对植物生产的阳光）
	    if (mode == 1) {
	        //velocity_y += gravity;
			gravity = 0.5
			velocity_x = 0
			velocity_y = 0
	    }
		else {
			gravity = 0
			hspeed = 0
			vspeed = 0
			velocity_y = 3
			ground_level = ground_level1
			x = x1
		}
    
	    // 更新位置
	    x += velocity_x;
	    y += velocity_y;
    
	    // 检查是否落地
    
	}

	// 自动收集计时（只在落地后开始）
	if (is_landed && global.auto_collect && !is_collected && !will_auto_collect) {
	    auto_collect_timer++;
	    if (auto_collect_timer >= global.auto_collect_delay) {
	        will_auto_collect = true;
	        //instance_create_layer(x, y, "Effects", obj_auto_collect_fx);
	    }
	}

	// 检测收集（无论是否落地）
	if (!is_collected) {
	    var mx = mouse_x;
	    var my = mouse_y;
	    var mouse_over = point_distance(x, y, mx, my) < collision_radius;
    
	    if (mouse_over || will_auto_collect) {
	        is_collected = true;
	        collect_timer = 0;
	        start_x = x;
	        start_y = y;
	        global.audio.play(snd_flame_collect, 1, false);
	    }
	}

	// 收集动画
	if (is_collected) {
	    collect_timer++;
	    var t = collect_timer / collect_duration;
    
	    // 缓动函数
	    if (ease_type == 2) {
	        t = 1 - (1 - t) * (1 - t);
	    }
    
	    x = start_x + (target_x - start_x) * t;
	    y = start_y + (target_y - start_y) * t;
    
    
    
    if (collect_timer >= collect_duration) {
        // 海克斯「火苗自然增长」：只放大拾取量，不改既有产火逻辑
        // 海克斯第二批「熠熠生辉」：每个火苗固定 +N，再走火苗获取倍率
        // 海克斯第三批「江人皇」：产能类美食的产量倍率（按产出来源卡判断）
        // 本体「产能类每次产出 +N」：同一次产出只让第一颗火苗吃，避免 ×3
        var _hx_src = "";
        if (variable_instance_exists(id, "hex_src_id")) _hx_src = hex_src_id;
        var _hx_pm = (_hx_src == "") ? 1.0 : hex_b3_prod_mult(_hx_src);
        var _hx_bn = hex_batch2_flame_flat();
        if (variable_instance_exists(id, "hex_prod_first") && hex_prod_first) {
            _hx_bn += hex_card_prod_bonus(_hx_src);
        }
        // 不公的契约·光明：每个火苗价值 +50
        _hx_bn += hex_b3_contract_flame_flat();
        global.flame += (value * _hx_pm + _hx_bn) * hex_flame_growth();
        // 不公的契约·光明：火苗溢出时产火的美食受伤
        if (_hx_src != "" && hex_b3_contract_on("light")
            && variable_global_exists("flame_cap") && global.flame_cap > 0
            && global.flame >= global.flame_cap) {
            with (obj_card_parent) {
                if (self.plant_id == _hx_src && self.hp > 0) {
                    self.hp = max(1, self.hp - self.max_hp * 0.05);
                }
            }
        }
	        //var fx = instance_create_layer(target_x, target_y, "Effects", obj_sun_fx);
	       // fx.value = value;
	        instance_destroy();
	    }
	}
}