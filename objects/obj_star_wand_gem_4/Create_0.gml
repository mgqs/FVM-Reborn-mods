image_xscale = 1.8;
image_yscale = 1.8;
image_speed = 0;
on_click = false;
gem_id = "star_wand_gem_4";
gem_info = get_gem_info(gem_id);
gem_level = get_gem_level(gem_id);

if (gem_level > gem_info.max_level)
    gem_level = gem_info.max_level;

cooldown = 0;
cooldown_timer = 0;
