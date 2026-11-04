image_xscale = 0.9
image_yscale = 0.9
image_speed = 0

on_click = false
gem_id = "laser_gem"
gem_info = get_gem_info(gem_id)
gem_level = get_gem_level(gem_id)

if(gem_level > gem_info.max_level) gem_level = gem_info.max_level

cooldown = gem_info.cooldown[gem_level] * 60
// 海克斯二期：宝石三件套（技能冷却倍率，非海克斯下恒 1.0）
cooldown = cooldown * hex_b3_gem_cd_mult()
cooldown_timer = gem_info.first_cooldown * 60//cooldown

range = gem_info.range[gem_level]