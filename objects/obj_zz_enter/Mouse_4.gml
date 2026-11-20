if (room == room_battle) exit;
if (obj_player_info_ui.menu_type != 0 || instance_exists(obj_zz_bg)) exit;
// 🔴 2026-11-20：商城（含正在播关闭动画的那一小段）还在时不叠开转转。
//   商城面板的菜单类型已经在关闭瞬间被清零，光靠 menu_type 拦不住，
//   叠上去以后商城的购买按钮会和兑换页按钮重合、抢走点击（抽卡/欧皇模式会弹
//   「抽卡模式无法购买卡片」）。这里把「面板还在」也当成占用。
if (instance_exists(obj_shop_bg)) exit;
if (!point_in_rectangle(mouse_x, mouse_y, x, y, x + sprite_width, y + sprite_height)) exit;

audio_play_sound(snd_button, 0, 0);
instance_create_depth(room_width / 2, room_height / 2, -5, obj_zz_bg);
obj_player_info_ui.menu_type = 4;
obj_world_map_button.world_map = 2;
