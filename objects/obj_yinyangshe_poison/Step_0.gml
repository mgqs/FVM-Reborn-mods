// obj_yinyangshe_poison Step 事件
// 跟着宿主走 → 到点跳一次伤害 → 跳满 yy_ticks 次自毁。
if (global.is_paused)
    exit;

var _host = yy_host;
if (!instance_exists(_host) || _host.hp <= 0)
{
    instance_destroy();
    exit;
}

// 贴在前爪上方，别盖住老鼠本体的血条
x = _host.x;
y = _host.y - 62;

yy_anim++;
if (yy_anim mod 3 == 0)
    image_index = (image_index + 1) mod sprite_get_number(sprite_index);

yy_timer++;
if (yy_timer < yy_tick_gap)
    exit;

yy_timer = 0;

// 每次跳总伤害的三分之一（最后一次补足余数，保证总量精确）
var _dmg = max(1, round(yy_total / max(1, yy_ticks)));
if (yy_ticks <= 1)
    _dmg = max(1, yy_total);

with (_host)
{
    damage_amount = _dmg;
    damage_type = "normal";
    event_user(0);
}

yy_ticks--;
if (yy_ticks <= 0)
    instance_destroy();
