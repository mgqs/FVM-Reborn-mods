if (global.is_paused) exit;

// ── 一次性爆炸（彩虹蛇死亡）──：不跟本体、不查血量，播完 7 帧就销毁
if (standalone){
    burst_t++;
    var _last_i = sprite_get_number(sprite_index) - 1;
    var _fi = burst_t div burst_speed;
    if (_fi > _last_i){
        instance_destroy();
        exit;
    }
    image_index = _fi;
    image_alpha = 1;
    exit;
}

if (!instance_exists(parent_plant)){
    instance_destroy();
    exit
}

x = parent_plant.x;
y = parent_plant.y;
depth = parent_plant.depth - 30;

// 形态可能在卡 Create 之后才赋值 → 每帧按本体的 shape 兜一次
var _ps = parent_plant.shape;
if (_ps == 1)      sprite_index = spr_caihongshe_shield_1;
else if (_ps == 2) sprite_index = spr_caihongshe_shield_2;
else               sprite_index = spr_caihongshe_shield;

// 7 帧展开，播完停最后一帧
anim_t++;
var _last = sprite_get_number(sprite_index) - 1;
image_index = min(_last, anim_t div 4);

// 本体破了就淡出（素材没有破损档，用透明度示意）
if (parent_plant.hp <= parent_plant.max_hp * 0.33) image_alpha = 0.55;
else if (parent_plant.hp <= parent_plant.max_hp * 0.66) image_alpha = 0.8;
else image_alpha = 1;
