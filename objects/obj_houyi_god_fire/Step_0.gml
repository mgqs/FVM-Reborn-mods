if (global.is_paused)
    exit;

timer++;
var total_frames = sprite_get_number(sprite_index);
var total_time = total_frames * 5;
// 海克斯二期：允许外部指定寿命（以我残躯化烈火 10 秒 / 重燃的火光 3 秒）
if (variable_instance_exists(id, "hex_life") && hex_life > 0) total_time = hex_life;
var damage_interval = total_time / 10;
image_index = floor(timer / 5);

if (image_index >= total_frames)
    image_index = total_frames - 1;

// 注意：伤害写在 Other_10（= 用户事件 0）。原来这里写的是 event_user(10)，
// 事件号对不上（用户事件 10 → Other_20，这个对象根本没有），
// 结果火焰只有画面、一点伤害都不掉 —— 「以我残躯化烈火 / 重燃的火光」不生效的根因
if (floor((timer - 1) / damage_interval) != floor(timer / damage_interval))
    event_user(0);

if (timer >= total_time)
    instance_destroy();
