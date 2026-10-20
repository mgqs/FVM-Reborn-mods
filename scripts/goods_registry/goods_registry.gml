function goods_registry_init(){
	global.goods_map = ds_map_create()
	global.goods_id_pool = []
}

function register_goods(goods_id,data){
	if (!ds_map_exists(global.goods_map, goods_id)) {
		array_push(global.goods_id_pool, goods_id)
	}
	global.goods_map[? goods_id] = data
}
