global.menu_screen = true

depth = -1200

// 强制清除application_surface，避免上一房间图像残留
if surface_exists(application_surface){
	surface_set_target(application_surface);
	draw_clear_alpha(c_black, 0); // 用透明黑色清除surface，alpha值0表示完全透明
	surface_reset_target();
}


instance_create_depth(1355,820,-2,obj_startgame_button)
instance_create_depth(100,0,-2,obj_player_info_ui)

/// @type {Asset.GMObject.EventEntranceList} 
var _entrance_list = instance_create_depth(0, 0, -2, EventEntranceList)
_entrance_list.set_position(600,20)
              .set_size(900, 300)


if not instance_exists(obj_menu_music_controller){
	var mus_inst = instance_create_depth(0,0,0,obj_menu_music_controller)
	mus_inst.menu_music = mus_town
}
if not instance_exists(obj_world_map_button){
	instance_create_depth(1670,80,0,obj_world_map_button)
}
instance_create_depth(room_width-210,room_height,-1,obj_player_menu_bg)
timer = 0

/// @description preload textures

global.laboretory_room = false




self.texture_to_load = [
	"UI",
	"cards",
	"enemy_delicious",
	"enemy_volcanic",
	"bullet",
	"effects",
	"player",
	"maps",
	"enemy_floating",
	"enemy_tower",
	"pack_explore_camp"
]

self.texture_count = array_length(self.texture_to_load)
self.texture_loaded = 0
global.preloaded = variable_global_exists("preloaded") ? global.preloaded : false
self.display_progress = 0

if !global.preloaded{
	instance_create_depth(-800,-800,0,obj_update_checker_btn)
}

function after_texture_load() {
	if (ui_anim_on(1)) self.outro_t = 0
    scribble_font_set_default("font_hei")
    scribble_font_bake_outline_4dir("font_hei", "font_hei_outline_4dir_black", c_dkgray, false)
    
    // 字体缺失字符适配：将导出字体中的全部字形合并到各主字体。
    // 情报岛文案覆盖面很大，手工维护少数字符会持续产生方框。
    //
    // 只有 font_yuan / font_hei 需要补字：它们是全游戏主字体。
    // font_song 仅被 obj_card_slot/Draw_0 用来画快捷键名（keyboard_get_string 只返回 ASCII，
    //   而 font_song 自带的 2136 字里 ASCII 95/95 全覆盖），font_song2 全工程无绘制引用。
    // 若把它们也列进目标，每局会白灌约 8000 个永远画不出来的汉字；而
    // __scribble_glyph_duplicate 每补一个字都要 ds_grid_resize 把整张字形表加宽一列，
    // 成本接近 O(N²)，是开场「加载完成」卡顿的主要来源。
    var _target_fonts = ["font_yuan", "font_hei"];
    // 源只留两个主汉字字体：font_song / font_song2 对它们唯一「独有」的字形是 U+007F(DEL)，
    // 是永远不会上屏的控制符，留在源里只会白白多遍历 4442 次。
    var _source_fonts = ["font_yuan", "font_pixel"];

    for (var _fi = 0; _fi < array_length(_target_fonts); _fi++) {
        var _tfont = _target_fonts[_fi];
        if (!scribble_font_exists(_tfont)) continue;

        for (var _si = 0; _si < array_length(_source_fonts); _si++) {
            var _sfont = _source_fonts[_si];
            if (scribble_font_exists(_sfont) && _sfont != _tfont) {
                // overwrite=false 只补目标字体没有的字形，保留原字体已有字形。
                scribble_super_glyph_copy_all(_tfont, _sfont, false);
            }
        }
    }

	if !global.preloaded{
		with obj_update_checker_btn{
			event_user(1)
		}
		global.preloaded = true;
	}
	obj_player_info_ui.menu_type = 0
	obj_world_map_button.world_map = 0

	// 从跨服远征关卡返回时，恢复跨服远征界面
	if (global.cross_server_return_page >= 0) {
	    var _cs_bg = instance_create_depth((room_width / 2) - 5, room_height / 2, -100, obj_cross_server_bg);
	    _cs_bg.selected_page = global.cross_server_return_page;
	    _cs_bg.refresh_level_buttons();
	    obj_player_info_ui.menu_type = 4;
	    obj_world_map_button.world_map = 2;
	    global.cross_server_return_page = -1;
	}
}

function pre_load_texture() {
    if (global.preloaded) return;
	
	obj_player_info_ui.menu_type = 4
	obj_world_map_button.world_map = 2
	
    if (self.animating) {
        var _target = self.texture_loaded;
        self.display_progress = lerp(self.display_progress, _target, 0.1);

        if (abs(self.display_progress - _target) < 0.01) {
            self.display_progress = _target;
            self.animating = false;
            
            if (self.texture_loaded >= self.texture_count) {
                after_texture_load();
            }
        }
        return;
    }

    if (self.texture_loaded < self.texture_count) {
        texture_prefetch(self.texture_to_load[self.texture_loaded]);
        self.texture_loaded += 1;
        self.animating = true;
    }
}


self.total_progress_bar_width = 700
self.active_bg = $fde98b
self.inactive_bg = c_white
self.active_width = 0
self.offset_x = (room_width - self.total_progress_bar_width) / 2
self.offset_y = (room_height/2 + 250)
self.animating = false
self.outro_t = -1
self.outro_frames = 48
function on_draw() {
    if (self.outro_t < 0) {
        if (global.preloaded) return;
        if (!self.animating && self.texture_loaded == 0) return;
    }
    var _out = 0;
    if (self.outro_t >= 0) {
        _out = clamp(self.outro_t / self.outro_frames, 0, 1);
        _out = 1 - power(1 - _out, 3);
    }
    var _fade = 1 - _out;

    draw_set_colour(c_black);
    draw_set_alpha(0.8 * _fade);
    draw_rectangle(0, 0, room_width, room_height, false);
    draw_set_alpha(_fade);

    var _ratio = (self.texture_count > 0) ? (self.display_progress / self.texture_count) : 0;
    var _current_width = self.total_progress_bar_width * _ratio;

    var _x1 = self.offset_x;
    var _y1 = self.offset_y;
    var _bar_h = 20;

    draw_set_color(self.inactive_bg);
    draw_rectangle(_x1 - 2, _y1 - 2, _x1 + self.total_progress_bar_width + 2, _y1 + _bar_h + 2, false);

    draw_set_color(self.active_bg);
    draw_rectangle(_x1, _y1, _x1 + _current_width, _y1 + _bar_h, false);
	draw_sprite_ext(spr_game_logo,0,room_width/2,room_height/3 + 50 * _out,1,1,0,c_white,_fade)
    
	draw_set_valign(fa_left)
	draw_set_halign(fa_top)
    draw_set_color(c_white);
    draw_set_font(font_yuan);
	var _text = "加载完成！"
	if self.texture_loaded <= array_length(self.texture_to_load)-1{
		_text = "加载中 " + string(self.texture_loaded) + "/" + string(self.texture_count) + " " + self.texture_to_load[clamp(self.texture_loaded,0,array_length(self.texture_to_load)-1)];
	}
    draw_text(_x1, _y1 - 30, _text);
	draw_set_valign(fa_middle)
	draw_set_halign(fa_center)
	draw_set_colour(c_yellow)
	draw_text(_x1+self.total_progress_bar_width/2, _y1 - 80, "本游戏为免费开源游戏，任何付费获取方式均为诈骗\n游戏作者B站名称：Spring曙光");
    draw_set_alpha(1)
}

// 纹理已预加载时，直接在 Create 阶段恢复跨服远征界面（首次加载走 after_texture_load）
if (global.preloaded && global.cross_server_return_page >= 0) {
    var _cs_bg = instance_create_depth((room_width / 2) - 5, room_height / 2, -100, obj_cross_server_bg);
    _cs_bg.selected_page = global.cross_server_return_page;
    _cs_bg.refresh_level_buttons();
    obj_player_info_ui.menu_type = 4;
    obj_world_map_button.world_map = 2;
    global.cross_server_return_page = -1;
}
