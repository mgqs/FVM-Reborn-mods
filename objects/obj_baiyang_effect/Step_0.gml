if (global.is_paused)
    exit;

timer++;
image_index = floor(timer / flash_speed) % anim_frames;
x += move_speed;

if (x > 2200)
    instance_destroy();

with (obj_enemy_parent)
{
    // 2026-11-16 用户口径：**所有 BOSS 都不吃冲撞秒杀**（撞不飞、只扣攻击力），原来写的是
    //   `is_boss && global.map_name == "跨服远征"` —— 只有古堡那一章算跨服，
    //   梦魇天空 / 灼热地域 / 水火之间 / 巫毒研究所 的 map_name 都不是「跨服远征」
    //   （进关时 room_transition 会用 register_map 的 name 覆盖），于是变异钢铁侠 / 变异绿巨
    //   这些新章 BOSS、以及美味岛的变异火渣 / 变异冰渣 全都被撞飞 + 秒杀。
    //   现在不再看地图名：BOSS 统一走下面 crash_immune_enemy 的「只扣血」分支。
    if (hp > 0 && grid_row == other.grid_row && abs(x - other.x) <= 100)
    {
        // 冲撞秒杀豁免：只有魂系鼠与 BOSS，其余敌人一律撞死
        if (crash_immune_enemy(id) || array_get_index(other.ignore_list, mouse_id) != -1)
        {
            if (array_get_index(other.hit_array, id) == -1)
            {
                hp -= other.atk;
                event_user(0);
                array_push(other.hit_array, id);
            }
        }
        else
        {
            var inst = instance_create_depth(x, y, depth, obj_knock_back_effect);
            inst.sprite_index = sprite_index;
            inst.image_index = image_index;
            instance_destroy();
        }
    }
}
