var _sel = (obj_shop_bg.shop_button_select == button_index)
image_index = _sel ? 1 : 0
if (_sel && !tab_sel_last) tab_pop_t = 0
tab_sel_last = _sel
tab_pop_t += ui_anim_dt()
// btn_scale：逐个页签自定义基准缩放（转职凭证页签 159×37，要按高度对齐到 1.654）
// btn_scale_x：只改横向 —— 转职凭证页签收到 1.45（素材比前 5 个宽，全等比缩小会变矮）
var _base = variable_instance_exists(id, "btn_scale") ? btn_scale : 1.8
var _base_x = variable_instance_exists(id, "btn_scale_x") ? btn_scale_x : _base
var _s = _base
var _sx = _base_x
if (_sel && ui_anim_on(1)) {
	var _p = clamp(tab_pop_t / 0.18, 0, 1)
	var _c1 = 1.70158
	var _e = 1 + (_c1 + 1) * power(_p - 1, 3) + _c1 * power(_p - 1, 2)
	var _k = lerp(0.92, 1, _e)
	_s = _base * _k
	_sx = _base_x * _k
}
image_xscale = _sx
image_yscale = _s
