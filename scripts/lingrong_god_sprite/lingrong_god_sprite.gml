/// @function lingrong_god_sprite(_in_water, _shape)
/// @description 灵榕神（魔导士软糖）按「脚下是否水面 + 形态」取用精灵。
///   水面（terrain.type == "water"）：
///     shape 0 → spr_lingrong_god_water
///     shape 1 → spr_lingrong_god_1_water
///     shape 2 → spr_lingrong_god_2_water
///   其余地形（陆地 / 岩浆 / 海底等非 water）：
///     shape 0 → spr_lingrong_god_nowater
///     shape 1 → spr_lingrong_god_1_nowater
///     shape 2 → spr_lingrong_god_2_nowater
///   ⚠️ 两套精灵的帧布局不同，切换时帧边界要一起改（见 obj_lingrong_god/Step_0）：
///     water  ：1~5 变身（image_index 0~4）、6~14 待机循环（5~13），共 14 帧
///     nowater：1~4 变身（image_index 0~3）、5~16 待机循环（4~15），共 16 帧
function lingrong_god_sprite(_in_water, _shape) {
    if (_in_water) {
        if (_shape == 1) return spr_lingrong_god_1_water;
        if (_shape == 2) return spr_lingrong_god_2_water;
        return spr_lingrong_god_water;
    }
    if (_shape == 1) return spr_lingrong_god_1_nowater;
    if (_shape == 2) return spr_lingrong_god_2_nowater;
    return spr_lingrong_god_nowater;
}
