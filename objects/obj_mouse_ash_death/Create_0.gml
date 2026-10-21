// 对象池复用（obj_pool_acquire → instance_change）不会把 sprite_index 恢复成对象默认精灵，
// 回收时实例在 obj_pool_holder 上已被置成 -1，复用时就会把 -1 带进 Draw → 崩
// （报错：draw_sprite_ext argument 1 invalid reference to (sprite) - requested -1）。
// Create 每次复用都会重跑，这里显式指回默认灰烬图；
// 大范围秒杀（光明神圣光这类）一次生成很多特效，最容易踩到复用路径。
sprite_index = spr_mouse_ash_death;

image_xscale = 1.8
image_yscale = 1.8
image_speed = 0
timer = 0
life = 90
can_destroy = false
special_ash = false
hit_shader = hit_effect_2