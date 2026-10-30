/// obj_hex_list_btn —— 设置页「已有词条」入口
/// 只在海克斯模式开启时创建（docs 5.5.1）

depth = -1;
hovered = false;
label   = "已有词条";

if (!hex_active()) instance_destroy();

var _n = hex_unlocked_total();
label = "已有词条 " + string(_n);
