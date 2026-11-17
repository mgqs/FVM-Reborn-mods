/// 弹簧虎 弹体 Destroy（命中后做 3×3 溅射；没命中直接飞出图外则不溅射）
if (!instance_exists(hitted_enemy)) exit;

var _cx = hitted_enemy.x;

with (obj_enemy_parent){
    if (hp <= 0) continue;
    if (id == other.hitted_enemy) continue;
    // 3×3：本行 ±1 行、命中点左右各 1.5 格
    if (abs(grid_row - other.row) > other.splash_cells) continue;
    if (abs(x - _cx) > global.grid_cell_size_x * 1.5) continue;
    // 2026-11-17 用户口径：溅射范围 = 空中 / 陆地 / 地下，**不跟子弹本体类型走**；
    //   障碍、幽灵、非主流不在这三类里，所以不吃溅射
    if (target_type != "normal" && target_type != "air" && target_type != "underground") continue;
    // 只有「地精站在地面」（type 仍写 underground）才排除；普通地鼠 / 牙医鼠这类
    //   underground 敌人本来就在地下，照常吃溅射
    if (is_walking_dijing(id)) continue;

    damage_amount         = other.damage * other.splash_ratio;
    damage_type           = other.damage_type;
    damage_source_object  = obj_tanhuanghu;
    damage_source_card_id = "tanhuanghu";
    if (variable_instance_exists(id, "ly_dig_hittable")) ly_dig_hittable = true;
    event_user(0);
    damage_source_card_id = "";
}
