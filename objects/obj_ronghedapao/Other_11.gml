// obj_ronghedapao 开火（event_user(1)）：朝本行第九列投一枚巧克力炸弹
// 落点固定 target_col = 8（格子 0 起算，第 9 格）—— 2026-11-03 用户口径：**与普通巧克力大炮一致**
//   （普通炮在 obj_chocolate_cannon/Other_11 里就是 target_col = 8；融合炮原来是 7，早一格）
// 出弹口 = 卡片上那颗球的位置（精灵里球心约在原点上方 57px，卡片按 1.8 倍绘制 ≈ 100px），
// depth + 1 → 生成在卡片后面：球从大炮后方/炮口升起来，不会一个大球直接盖在卡片正面。
var inst = instance_create_depth(x, y - 100, depth + 1, obj_ronghedapao_bullet)
inst.target_col = 8
inst.target_row = grid_row
inst.damage = atk
inst.blast_shape = shape
inst.blast_row_half = blast_row_half
inst.blast_col_half = blast_col_half
inst.crush_kill = crush_kill
inst.target_row = grid_row
inst.damage = atk
inst.blast_shape = shape
inst.blast_row_half = blast_row_half
inst.blast_col_half = blast_col_half
inst.crush_kill = crush_kill

// 飞行贴图用「自己形态」那颗巧克力球（0 / 1 / 2 转的球各不相同，都取自该形态 effect 首帧）
if shape == 0{
	inst.sprite_index = spr_ronghedapao_bullet
}
else if shape == 1{
	inst.sprite_index = spr_ronghedapao_bullet_1
}
else{
	inst.sprite_index = spr_ronghedapao_bullet_2
}
