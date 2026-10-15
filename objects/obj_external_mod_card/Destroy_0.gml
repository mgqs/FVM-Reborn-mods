var reason = variable_instance_exists(id, "is_shoveled") && is_shoveled ? "shovel" : (hp <= 0 ? "death" : "removed");
if (variable_instance_exists(id, "mod_lua_handle") && mod_lua_handle >= 0) {
    // Destruction notifications cannot issue spawn/remove commands during room teardown.
    native_mod_lua_call(mod_lua_handle, "on_destroy", json_stringify({id: id, reason: reason}));
    native_mod_lua_destroy(mod_lua_handle);
    mod_lua_handle = -1;
}
event_inherited();
