damage = 0
move_speed = 18
row = 0
shape_bullet = 0
hitted_enemy = ds_list_create()
target_type = "normal"
damage_type = "normal"
hittable_types = get_hittable_enemy_types(target_type)
// 2026-11-11：蛋蛋兔是灰烬类卡，必须能吃到「dance(走行/腾空)」—— 高跷鼠 / 非主流鼠走行。
//   get_hittable_enemy_types("normal") 的桶里没有 dance，这里补一个，
//   只影响本子弹（obj_dandantu_bullet 只由蛋蛋兔生成），不污染其它普通弹丸。
array_push(hittable_types, "dance")
hit_tick = 0;
pooled = false
