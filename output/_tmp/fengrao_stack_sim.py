# -*- coding: utf-8 -*-
"""复现「至尊丰饶神被时光机改星后倍率翻倍」的成因，并对比修复前后。

模型（贴 scripts/mod_build_buff_grid + obj_fengrao_god/Step_0 的实际逻辑）：
  * 变星（mod_set_card_level:84）把 buff_cells_refreshed 置 false
  * 丰饶神 Step_0 的 if (!buff_cells_refreshed) 分支：登记 buff_sources + 重建格子
  * rebuild_buff_grid 逐条 apply_buff；buff_stacking → stack_grid += v, stack_count++（max_stacks=3）
  * 同一实例在 buff_sources 里出现 N 次 → 每轮重建叠 N 层
"""

MAX_STACKS = 3
# shape 3（至尊丰饶神）atk 表，index = 星级；应当倍率 = atk / 100
ATK = [216, 218, 220, 222, 227, 232, 238, 244, 250, 256, 281, 326, 371, 416, 461, 506, 551, 600, 650]


def run(star_path, dedupe):
    """star_path: 依次经历的星级；返回每一步的实际倍率。"""
    sources = []          # 模拟 global.buff_sources（实例 id 列表）
    refreshed = False
    star = star_path[0]
    out = []

    def rebuild():
        stack_sum = 0.0
        count = 0
        for inst in sources:
            v = ATK[star] / 100
            if count < MAX_STACKS:
                stack_sum += v
                count += 1
        return stack_sum if count else 1.0

    for i, star in enumerate(star_path):
        if i > 0:                      # 时光机改星 → 置 dirty
            refreshed = False
        if not refreshed:              # Step_0 的 !buff_cells_refreshed 分支
            if dedupe:
                if 1 not in sources:
                    sources.append(1)
            else:
                sources.append(1)
            refreshed = True
        out.append((star, ATK[star] / 100, rebuild()))
    return out


path = [8, 9, 7, 8]
for dedupe, name in ((False, "修复前（重复登记）"), (True, "修复后（去重）")):
    print(name)
    for star, should, actual in run(path, dedupe):
        print(f"  {star}星  应当 {should:.2f}   实际 {actual:.2f}   叠层 {actual / should:.0f}")
    print()
