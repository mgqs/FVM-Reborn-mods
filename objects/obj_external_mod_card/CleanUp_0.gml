// Room changes also release Lua states; Destroy may already have released it.
if (variable_instance_exists(id, "mod_lua_handle") && mod_lua_handle >= 0) {
    native_mod_lua_destroy(mod_lua_handle);
    mod_lua_handle = -1;
}
