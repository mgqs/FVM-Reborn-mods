global._move_instance_pre_arr = []
global._move_instance_map = ds_map_create()
global._last_platform = -1

#macro instance_create_depth_origfunc instance_create_depth
#macro instance_create_depth          instance_create_depth_define

#macro instance_destroy_origfunc instance_destroy
#macro instance_destroy          obj_pool_instance_destroy


function instance_create_depth_define(_x, _y, _depth, _obj, _variables = undefined) {

	if (is_undefined(_variables) && obj_pool_is_poolable(_obj)) {
		var _inst = obj_pool_acquire(_obj, _x, _y, _depth);
		array_push(global._move_instance_pre_arr,_inst);
		if (_obj == obj_platform)
			global._last_platform = _inst;
		return _inst;
	}

	// GameMaker's native creator accepts four arguments. Keep the spawn payload in
	// a short-lived global so the object's Create event can consume it immediately.
	var _previous_context = variable_global_exists("_external_spawn_context") ? global._external_spawn_context : undefined;
	if (!is_undefined(_variables)) global._external_spawn_context = _variables;
	var _inst = instance_create_depth_origfunc(_x, _y, _depth, _obj);
	if (!is_undefined(_variables)) global._external_spawn_context = _previous_context;
	array_push(global._move_instance_pre_arr,_inst);
	if (_obj == obj_platform)
		global._last_platform = _inst;

	return _inst;
}
