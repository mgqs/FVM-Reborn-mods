function goods_registry_init(){
	global.goods_map = ds_map_create()
}

function register_goods(goods_id,data){
	global.goods_map[? goods_id] = data
}