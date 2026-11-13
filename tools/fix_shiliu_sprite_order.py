# -*- coding: utf-8 -*-
r"""
修复 spr_shiliu_0 / _1 / _2 的帧顺序（2026-11-13，第三版：生长 → 成熟 13 帧 → 爆炸）

背景
----
素材 `桌面\皮特\炎帝终转+石榴\spr-shiliu\{0,1,2}shape` 导出的帧顺序是：
    [生长 1..9]  [爆炸 10..M]  [成熟待机 M+1..N]
「生长段」果实宽度 62→74px 单调增（不是循环），「成熟段」宽度稳定 82~88px 且末帧 N
与段首帧 M+1 逐字节相同（循环闭环）。

卡片实际的播放顺序是 **先生长、再成熟、最后爆炸**（用户 2026-11-13 口径），
而源文件把爆炸夹在中间。本脚本原地重写每帧 PNG（GUID / .yy / 原点 / 帧总数全不动）：

    新顺序 = [生长 9][成熟 13][爆炸 E]

  · 成熟段取完整 13 帧（M+1..N，含与段首相同的闭环帧）—— 这样帧表最后一段一定是爆炸，
    不会出现「最后一帧是一颗完好的果实」这种错位（用户 21:33 反馈）
  · 总数 9 + 13 + E = N（0 转 25 / 一转 32 / 二转 33 都正好整除）

对象侧（obj_shiliu_baobao_bing）对应：
    idle_anim  = 21            // idx 0..21 = 生长 9 + 成熟 13
    attack_anim = 3 / 10 / 11  // 爆炸段从 idx 22 开始

用法
----
    python tools/fix_shiliu_sprite_order.py            # 执行
    python tools/fix_shiliu_sprite_order.py --check    # 只校验当前顺序
"""
import io
import json
import os
import re
import shutil
import sys

SRC_ROOT = r'C:\Users\18203\Desktop\皮特\炎帝终转+石榴\spr-shiliu'
PROJ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 每个形态：源目录 + 各段在源里的 1-based 帧号区间
#   grow  : 生长（1..9）
#   mature: 成熟待机（M+1..N，13 帧，含闭环重复帧）
#   blast : 爆炸（10..M）
SPEC = {
    'spr_shiliu_0': {'dir': '0shape', 'grow': (1, 9),  'blast': (10, 12), 'mature': (13, 25)},
    'spr_shiliu_1': {'dir': '1shape', 'grow': (1, 9),  'blast': (10, 19), 'mature': (20, 32)},
    'spr_shiliu_2': {'dir': '2shape', 'grow': (1, 9),  'blast': (10, 20), 'mature': (21, 33)},
}

GROW_LEN = 9       # 生长帧数
MATURE_LEN = 13    # 成熟待机帧数（含闭环帧）
IDLE_LEN = GROW_LEN + MATURE_LEN   # 22 → idle_anim = 21


def frame_guids(spr):
    p = os.path.join(PROJ, 'sprites', spr, spr + '.yy')
    raw = io.open(p, encoding='utf-8').read()
    d = json.loads(re.sub(r',(\s*[}\]])', r'\1', raw))
    return [f['name'] for f in d['frames']]


def layer_png(spr, guid):
    """返回该帧需要同步写入的**全部** PNG 路径。

    GMS 的精灵目录有两套图，必须同时改，否则游戏读到的还是旧帧序：
      ① `sprites/<spr>/layers/<帧GUID>/<图层GUID>.png`  —— 图层源图（IDE 编辑器用）
      ② `sprites/<spr>/<帧GUID>.png`                    —— 顶层合成图（**运行时/IDE 预览实际读这个**）
    本项目的卡片精灵都是「单图层、无偏移」，所以两者内容完全一样，直接同一张 src 覆盖即可。
    """
    base = os.path.join(PROJ, 'sprites', spr)
    layer_dir = os.path.join(base, 'layers', guid)
    pngs = [f for f in os.listdir(layer_dir) if f.lower().endswith('.png')]
    assert len(pngs) == 1, (spr, guid, pngs)
    out = [os.path.join(layer_dir, pngs[0])]

    top = os.path.join(base, guid + '.png')
    if os.path.exists(top):
        out.append(top)
    return out


def build_order(spec):
    """新顺序 = 生长 + 成熟 + 爆炸（全部 1-based 源帧号）"""
    grow = list(range(spec['grow'][0], spec['grow'][1] + 1))
    mature = list(range(spec['mature'][0], spec['mature'][1] + 1))
    blast = list(range(spec['blast'][0], spec['blast'][1] + 1))
    return grow + mature + blast


def main():
    check_only = '--check' in sys.argv
    for spr, spec in SPEC.items():
        src_dir = os.path.join(SRC_ROOT, spec['dir'])
        order = build_order(spec)
        guids = frame_guids(spr)
        assert len(order) == len(guids), '%s 帧数不匹配：新顺序 %d，精灵 %d' % (spr, len(order), len(guids))
        assert sorted(order) == list(range(1, len(order) + 1)), '%s 源帧号不是 1..N 的一组排列' % spr

        blast_n = spec['blast'][1] - spec['blast'][0] + 1
        print('== %s  (%d 帧)  生长 idx 0..%d / 成熟 idx %d..%d / 爆炸 idx %d..%d'
              % (spr, len(guids),
                 GROW_LEN - 1,
                 GROW_LEN, GROW_LEN + MATURE_LEN - 1,
                 IDLE_LEN, IDLE_LEN + blast_n - 1))

        bad = 0
        for idx, src_no in enumerate(order):
            src = os.path.join(src_dir, '%d.png' % src_no)
            src_bytes = open(src, 'rb').read()
            for dst in layer_png(spr, guids[idx]):
                same = os.path.exists(dst) and open(dst, 'rb').read() == src_bytes
                if check_only:
                    if not same:
                        bad += 1
                        print('   idx %2d <- 源 %2d  不一致（%s）' % (idx, src_no, os.path.basename(os.path.dirname(dst))))
                    continue
                if not same:
                    shutil.copyfile(src, dst)
        if check_only:
            print('   校验：%d 帧，%d 帧不一致' % (len(order), bad))
        else:
            print('   已按新顺序重写 %d 帧' % len(order))


if __name__ == '__main__':
    main()

