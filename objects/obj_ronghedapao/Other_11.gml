// obj_ronghedapao 开火（event_user(1)）：朝本行第八列投一枚巧克力炸弹
// 落点固定 target_col = 7（与情报岛「落在本行第八列」一致；格子 0 起算，第九列才是 8）
// 出弹口 = 卡片上那颗球的位置（精灵里球心约在原点上方 57px，卡片按 1.8 倍绘制 ≈ 100px），
// depth + 1 → 生成在卡片后面：球从大炮后方/炮口升起来，不会一个大球直接盖在卡片正面。
var inst = instance_create_depth(x, y - 100, depth + 1, obj_ronghedapao_bullet)
inst.target_col = 7
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
