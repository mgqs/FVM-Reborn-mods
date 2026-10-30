if (global.is_paused)
{
    image_speed = 0;
    exit;
}

image_speed = 1;

// 错帧连发：延时期间不出现、不移动、不消耗寿命（用于八方向第二组子弹）
if (delay > 0)
{
    delay--;
    visible = false;
    exit;
}
visible = true;

// 燃烧后切换为火焰子弹精灵（与玉米射手一致，视觉反馈清晰）
if (burnt >= 1 && sprite_index != spr_fire_bullet)
{
    sprite_index = spr_fire_bullet;
    image_xscale = 1.8;
    image_yscale = 1.8;
}

timer++;

if (timer > max_life || x > 2200 || y > 1200 || x < -200 || y < -200)
{
    instance_destroy();
    exit;
}

image_angle = point_direction(0, 0, move_x, move_y);

x += move_x;
y += move_y;

// 命中判定：接全局索敌管线（obj_battle/Step_2 每帧建好 enemy_sx 扫掠索引 + enemy_col_n）
//   ★ 旧写法每帧、每颗子弹都要把「全表敌人」逐个跑一次判定 —— 鱿鱼一次齐射 16~22 发、
//     场上同时存在的子弹可达几十颗，这才是「鱿鱼放多了卡顿」的真正来源（不是本体索敌）
//   现在只处理「与子弹 x 轴扫掠窗口相交」的少量候选（bullet_sap_type_list 内部按代缓存，
//   同一帧多颗子弹共享同一份索引），并按全局间隔隔帧判定
//   安全性：子弹 8px/帧、判定步长 global.bullet_hit_interval(2) = 16px，
//          远小于「子弹 + 鼠」的合体碰撞宽度，不会跳过命中
hit_tick++;
if (hit_tick >= global.bullet_hit_interval)
{
    hit_tick = 0;

    if (variable_global_exists("enemy_by_type") && bullet_enemy_reachable(id))
    {
        for (var _t = 0; _t < array_length(hittable_types); _t++)
        {
            var _key = hittable_types[_t];
            if (!variable_struct_exists(global.enemy_by_type, _key)) continue;

            var _list = bullet_sap_type_list(id, _key);
            for (var _i = 0; _i < array_length(_list); _i++)
            {
                var _e = _list[_i];
                if (!instance_exists(_e) || _e.hp <= 0) continue;
                if (ds_list_find_index(hitted_enemy, _e.id) != -1) continue;
                if (!precise_bbox_collision(id, _e)) continue;

                has_hit = true;

                var _dmg = damage;
                var _is_burnt = burnt;

                with (_e)
                {
                    if (_is_burnt >= 1)
                        audio_play_sound(snd_fire_hit, 0, 0);
                    else
                        audio_play_sound(hit_sound, 0, 0);

                    damage_amount = _dmg;
                    damage_type = other.damage_type;
                    event_user(0);
                }

                ds_list_add(hitted_enemy, _e.id);
                instance_destroy();
                exit;
            }
        }
    }
}
