# -*- coding: utf-8 -*-
"""把 output/梦魇天空预览/build 下的 8 张成品底图写回 sprites/spr_mengyantiankong_N。

精灵目录结构（每个精灵）：
  sprites/spr_mengyantiankong_N/<frameId>.png                    ← 预览用副本
  sprites/spr_mengyantiankong_N/layers/<frameId>/<layerId>.png   ← 真正参与构建的帧
两份内容必须一致（实测 sha256 相同），所以两份都要覆盖。
原图先备份到 output/梦魇天空预览/backup/，可随时回滚。
"""
import glob
import os
import shutil

from PIL import Image

ROOT = r'D:\gameProject\FVM-Reborn-mod'
BUILD = os.path.join(ROOT, 'output', '梦魇天空预览', 'build')
BACKUP = os.path.join(ROOT, 'output', '梦魇天空预览', 'backup')
os.makedirs(BACKUP, exist_ok=True)

for n in range(8):
    src = os.path.join(BUILD, 'spr_mengyantiankong_%d.png' % n)
    im = Image.open(src).convert('RGBA')
    assert im.size == (1109, 597), (src, im.size)

    top = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n, '*.png'))
    layer = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % n,
                                   'layers', '*', '*.png'))
    assert len(top) == 1 and len(layer) == 1, (n, top, layer)

    for p in (top[0], layer[0]):
        bak = os.path.join(BACKUP, 'spr_mengyantiankong_%d' % n,
                           os.path.basename(os.path.dirname(p)) + '_' + os.path.basename(p))
        os.makedirs(os.path.dirname(bak), exist_ok=True)
        if not os.path.exists(bak):
            shutil.copy2(p, bak)
        im.save(p, 'PNG')
    print('spr_%d 已替换（顶层 + layer，原图备份至 backup/）' % n)
print('\n替换完成，原图在', BACKUP)
