/// 能量喵数值（来源：基本信息.xlsx「卡片信息」能量喵那一段）
/// 平射倍率走牌面 atk（存倍率×100，过喵时 atk/100）；投手倍率塞不下，单独放这里

/// @function nengliangmiao_thrower_mult(_level, _shape)
/// @desc 投手增幅倍率（整行投掷类，0~16 级）；二转额外 ×1.15（与平射倍率同口径）
function nengliangmiao_thrower_mult(_level, _shape) {
    var _t = [1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1,
              2.3, 2.5, 2.7, 2.9, 3.2, 3.5, 3.8, 4.1];
    var _v = _t[clamp(round(_level), 0, array_length(_t) - 1)];
    if (_shape >= 2) _v *= 1.15;
    return _v;
}

/// @function nengliangmiao_pass_mult(_atk)
/// @desc 平射增幅倍率 = 牌面攻击力 / 100（过喵时乘给子弹）
function nengliangmiao_pass_mult(_atk) {
    return _atk / 100;
}
