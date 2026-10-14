// Lua 5.4 bridge. Each card instance owns a state; no files, OS or native modules.
#include "json.hpp"
#include <cstdlib>
#include <memory>
#include <string>
#include <unordered_map>
extern "C" {
#include "../third_party/lua-5.4.8/src/lua.h"
#include "../third_party/lua-5.4.8/src/lauxlib.h"
#include "../third_party/lua-5.4.8/src/lualib.h"
}

using Json = nlohmann::json;
namespace {
struct Runtime {
    lua_State* L = nullptr;
    size_t bytes = 0;
    Json commands = Json::array();
    int budget = 0;
    ~Runtime() { if (L) lua_close(L); }
};
std::unordered_map<int, std::unique_ptr<Runtime>> states;
int next_id = 1;
thread_local std::string result;
constexpr size_t memory_limit = 8 * 1024 * 1024;
void* allocate(void* ud, void* ptr, size_t old_size, size_t new_size) {
    auto& r = *static_cast<Runtime*>(ud);
    if (!ptr) old_size = 0;
    if (!new_size) { std::free(ptr); r.bytes -= old_size; return nullptr; }
    if (new_size > memory_limit || r.bytes - old_size > memory_limit - new_size) return nullptr;
    void* p = std::realloc(ptr, new_size);
    if (p) r.bytes = r.bytes - old_size + new_size;
    return p;
}
Runtime& runtime(lua_State* L) {
    return **static_cast<Runtime**>(lua_getextraspace(L));
}
void hook(lua_State* L, lua_Debug*) {
    if (--runtime(L).budget <= 0) luaL_error(L, "Lua instruction limit exceeded");
}
void push_json(lua_State* L, const Json& j) {
    if (j.is_object()) {
        lua_newtable(L);
        for (auto it = j.begin(); it != j.end(); ++it) {
            push_json(L, it.value()); lua_setfield(L, -2, it.key().c_str());
        }
    } else if (j.is_array()) {
        lua_newtable(L);
        for (size_t i = 0; i < j.size(); ++i) { push_json(L, j[i]); lua_rawseti(L, -2, i + 1); }
    } else if (j.is_string()) {
        const auto& s = j.get_ref<const std::string&>(); lua_pushlstring(L, s.data(), s.size());
    } else if (j.is_boolean()) lua_pushboolean(L, j.get<bool>());
    else if (j.is_number()) lua_pushnumber(L, j.get<double>());
    else lua_pushnil(L);
}
Json read_json(lua_State* L, int index, int depth = 0) {
    if (depth > 8) return nullptr;
    index = lua_absindex(L, index);
    switch (lua_type(L, index)) {
    case LUA_TBOOLEAN: return bool(lua_toboolean(L, index));
    case LUA_TNUMBER: return lua_tonumber(L, index);
    case LUA_TSTRING: return std::string(lua_tostring(L, index));
    case LUA_TTABLE: {
        Json j = Json::object();
        lua_pushnil(L);
        int count = 0;
        while (lua_next(L, index)) {
            if (++count > 128) { lua_pop(L, 2); break; }
            if (lua_type(L, -2) == LUA_TSTRING) j[lua_tostring(L, -2)] = read_json(L, -1, depth + 1);
            lua_pop(L, 1);
        }
        return j;
    }
    default: return nullptr;
    }
}
int command(lua_State* L) {
    auto& r = runtime(L);
    if (r.commands.size() >= 128) return luaL_error(L, "Too many commands in one callback");
    Json j = lua_istable(L, 1) ? read_json(L, 1) : Json::object();
    j["op"] = lua_tostring(L, lua_upvalueindex(1));
    r.commands.push_back(std::move(j));
    return 0;
}
int invoke(lua_State* L) {
    const char* event = lua_tostring(L, 1);
    lua_getglobal(L, "card");
    if (!lua_istable(L, -1)) return luaL_error(L, "logic.lua must return a card table");
    lua_getfield(L, -1, event);
    if (lua_isnil(L, -1)) return 0;
    if (!lua_isfunction(L, -1)) return luaL_error(L, "Card callback must be a function");
    lua_pushvalue(L, 2);
    lua_getglobal(L, "state");
    lua_call(L, 2, 0);
    return 0;
}
int initialize(lua_State* L) {
    luaL_requiref(L, "_G", luaopen_base, 1); lua_pop(L, 1);
    luaL_requiref(L, LUA_MATHLIBNAME, luaopen_math, 1); lua_pop(L, 1);
    luaL_requiref(L, LUA_TABLIBNAME, luaopen_table, 1); lua_pop(L, 1);
    luaL_requiref(L, LUA_STRLIBNAME, luaopen_string, 1); lua_pop(L, 1);
    const char* forbidden[] = {"dofile", "loadfile", "load", "collectgarbage", "print"};
    for (auto name : forbidden) { lua_pushnil(L); lua_setglobal(L, name); }
    lua_newtable(L);
    const char* ops[] = {"shoot", "damage", "heal", "produce", "animate", "timer", "remove", "log"};
    for (auto op : ops) {
        lua_pushstring(L, op); lua_pushcclosure(L, command, 1); lua_setfield(L, -2, op);
    }
    lua_setglobal(L, "api");
    lua_newtable(L); lua_setglobal(L, "state");
    size_t size = 0;
    const char* source = lua_tolstring(L, 1, &size);
    if (luaL_loadbufferx(L, source, size, "logic.lua", "t") != LUA_OK) return lua_error(L);
    lua_call(L, 0, 1);
    if (!lua_istable(L, -1)) return luaL_error(L, "logic.lua must return a table");
    lua_setglobal(L, "card");
    return 0;
}
const char* reply(const Json& j) { result = j.dump(); return result.c_str(); }
}

extern "C" __declspec(dllexport) const char* ModLuaCreate(const char* source) {
    try {
        auto r = std::make_unique<Runtime>();
        r->L = lua_newstate(allocate, r.get());
        if (!r->L) return reply({{"ok", false}, {"error", "Cannot allocate Lua state"}});
        *static_cast<Runtime**>(lua_getextraspace(r->L)) = r.get();
        r->budget = 100;
        lua_sethook(r->L, hook, LUA_MASKCOUNT, 1000);
        lua_pushcfunction(r->L, initialize);
        lua_pushstring(r->L, source ? source : "");
        if (lua_pcall(r->L, 1, 0, 0) != LUA_OK) {
            std::string error = lua_tostring(r->L, -1) ? lua_tostring(r->L, -1) : "Lua initialization failed";
            return reply({{"ok", false}, {"error", error}});
        }
        const int id = next_id++;
        states.emplace(id, std::move(r));
        return reply({{"ok", true}, {"handle", id}});
    } catch (const std::exception& e) { return reply({{"ok", false}, {"error", e.what()}}); }
}
extern "C" __declspec(dllexport) const char* ModLuaCall(double handle, const char* event, const char* context) {
    try {
        auto it = states.find(static_cast<int>(handle));
        if (it == states.end()) return reply({{"ok", false}, {"error", "Invalid Lua handle"}});
        auto& r = *it->second;
        r.commands = Json::array();
        r.budget = 100;
        lua_settop(r.L, 0);
        lua_pushcfunction(r.L, invoke);
        lua_pushstring(r.L, event ? event : "");
        // Parsing context and building its table must also stay inside a protected Lua call.
        Json j = Json::parse(context ? context : "{}");
        // Context is bounded by the GML producer to at most 128 enemies.
        struct Context { const Json* j; } ctx{&j};
        lua_pushcfunction(r.L, [](lua_State* L) -> int {
            auto* c = static_cast<Context*>(lua_touserdata(L, 1)); push_json(L, *c->j); return 1;
        });
        lua_pushlightuserdata(r.L, &ctx);
        if (lua_pcall(r.L, 1, 1, 0) != LUA_OK) {
            std::string error = lua_tostring(r.L, -1) ? lua_tostring(r.L, -1) : "Lua memory limit exceeded";
            lua_settop(r.L, 0); return reply({{"ok", false}, {"error", error}});
        }
        if (lua_pcall(r.L, 2, 0, 0) != LUA_OK) {
            std::string error = lua_tostring(r.L, -1) ? lua_tostring(r.L, -1) : "Lua callback failed";
            lua_settop(r.L, 0); return reply({{"ok", false}, {"error", error}});
        }
        return reply({{"ok", true}, {"commands", r.commands}});
    } catch (const std::exception& e) { return reply({{"ok", false}, {"error", e.what()}}); }
}
extern "C" __declspec(dllexport) double ModLuaDestroy(double handle) {
    return states.erase(static_cast<int>(handle)) ? 0.0 : 1.0;
}
