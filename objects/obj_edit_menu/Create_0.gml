image_xscale = 1;
image_yscale = 1;

// 初始化变量
character_name = global.player_name; // 从全局变量获取当前角色名
player_attire_id_list = get_card_attire_list("player")//获取玩家时装列表
selected_attire_id = card_equipped_attire_id("player")//获取玩家当前装备时装
selected_attire_index = -1 // 当前选择的时装索引
if selected_attire_id != -1{
	selected_attire_index = array_get_index(player_attire_id_list,selected_attire_id)
}

// 创建保存按钮
var save_btn = instance_create_depth(x - 350, y + 280, depth-1, obj_edit_menu_button);
save_btn.button_text = "保存";
save_btn.btn_type = "save";
save_btn.parent = id; // 设置父对象以便通信

// 创建保存按钮
var open_save_folder_btn = instance_create_depth(x - 175, y + 280, depth-1, obj_edit_menu_button);
open_save_folder_btn.button_text = "存档文件夹";
open_save_folder_btn.btn_type = "open_save_folder";
open_save_folder_btn.parent = id; 

// 创建导出按钮
var export_btn = instance_create_depth(x, y + 280, depth-1, obj_edit_menu_button);
export_btn.button_text = "导出存档备份";
export_btn.btn_type = "export_save_backup";
export_btn.parent = id; 

// 创建导入按钮
var import_btn = instance_create_depth(x + 175, y + 280, depth-1, obj_edit_menu_button);
import_btn.button_text = "导入存档备份";
import_btn.btn_type = "import_save_backup";
import_btn.parent = id; 

// 创建取消按钮
var cancel_btn = instance_create_depth(x + 350, y + 280, depth-1, obj_edit_menu_button);
cancel_btn.button_text = "取消";
cancel_btn.btn_type = "cancel";
cancel_btn.parent = id;

// 创建输入框
input_field = instance_create_depth(x-210, y - 195, depth-1, obj_text_input);
input_field.text = character_name;
input_field.max_length = 16;
input_field.placeholder = "输入角色名";
input_field.width = 300;
input_field.active = true;

for(var i = 0 ; i < 5 ; i++){
	var btn3 = instance_create_depth(x - 200+140*i, y -88 , depth-1, obj_save_slot_select_btn);
	btn3.config_key = "save_slot";
	btn3.state = i;
}

var btn4 = instance_create_depth(x-220,y+90,depth-1,obj_player_attire_select_btn)
btn4.type = "prev"

var btn5 = instance_create_depth(x+420,y+90,depth-1,obj_player_attire_select_btn)
btn5.type = "next"

var btn6 = instance_create_depth(x - 280, y +175 , depth-1, obj_update_checker_btn);

sw_shown = selected_attire_index;
sw_from = selected_attire_index;
sw_t = -1;
sw_frames = 18;
sw_dir = 1;
sw_pending_dir = 0;
sw_surf = -1;
sw_win_l = x - 174;
sw_win_t = y - 16;
sw_win_w = 548;
sw_win_h = 224;

panel_anim_init(id, 0.28, 0.18, 260);
panel_anim_kids(id, [obj_edit_menu_button, obj_text_input, obj_save_slot_select_btn,
                     obj_player_attire_select_btn, btn6]);

function edit_attire_content_draw(_index, _dx, _dy) {
	if (_index != -1) {
		var _id = player_attire_id_list[_index];
		var _data = get_attire_info(_id);
		draw_sprite(_data.icon, 0, x + 100 + _dx, y + 95 + _dy);
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(x + 100 + _dx, y + 180 + _dy, _data.name);
	} else {
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_text(x - 75 + _dx, y + 100 + _dy, "无");
	}
}
