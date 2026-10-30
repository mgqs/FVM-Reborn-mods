// 非死亡方式移除（铲子等）：立即断开龙柱并让连接表现收尾
if (mixian_pillar != noone) {
	longzhu_bridge_disconnect(id);
	mixian_pillar = noone;
}

if (!mixian_dying) mixian_break_visuals();
mixian_release_bridge();

event_inherited();
