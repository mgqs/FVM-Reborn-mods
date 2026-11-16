// 合成屋演出中（融合 / 转职 / 进化）不许关：那三段都是「播完那一帧才落账」，提前关 = 白扣材料
//   （2026-11-11 用户口径；画面上这个 X 也会被 obj_craft_bg 的 Step 藏起来，这里是双保险）
// ⚠️ 2026-11-16：visible = false 只跳过 Draw，**Mouse 事件照样派发** —— 藏起来的 X 必须在这里拦，
//   否则融合确认弹窗（fusion_confirm）期间点一下 X 就把整个合成屋关了。
if (!visible) exit
if (obj_craft_bg.craft_anim_lock()) exit;

if not obj_craft_bg.is_submenu_opened{
	global.audio.play(snd_button,0,0)
	obj_craft_bg.close_timer = 2
}