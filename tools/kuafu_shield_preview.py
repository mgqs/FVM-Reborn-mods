# -*- coding: utf-8 -*-
"""跨服 BOSS 变异护盾（spr_kuafu_boss_shield）位置预览。

把立绘与护盾按「游戏内同 origin 对齐」的方式合成，方便在不进游戏的情况下
调 shield_dx / shield_dy / shield_sx / shield_sy。

用法:
    python tools/kuafu_shield_preview.py
    python tools/kuafu_shield_preview.py --out output/x.png
"""
import json
import os
import re
import sys

from PIL import Image, ImageDraw

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHIELD = 'spr_kuafu_boss_shield'

# 游戏内 BOSS 的 (x, y) 在预览画布上的落点
PX, PY = 600, 760


def load_yy(name):
    p = os.path.join(ROOT, 'sprites', name, name + '.yy')
    s = open(p, encoding='utf-8-sig').read()
    s = re.sub(r',(\s*[}\]])', r'\1', s)
    return json.loads(s)


def first_frame(name, idx=0):
    y = load_yy(name)
    f = y['frames'][idx]['name']
    im = Image.open(os.path.join(ROOT, 'sprites', name, f + '.png')).convert('RGBA')
    return im, y['sequence']['xorigin'], y['sequence']['yorigin']


def render(body_name, cfg, shield, shield_ox, shield_oy):
    body, ox, oy = first_frame(body_name)
    W, H = 1200, 1000
    canvas = Image.new('RGBA', (W, H), (0, 0, 0, 0))
    # 立绘：左上角 = (PX-ox, PY-oy)
    canvas.alpha_composite(body, (PX - ox, PY - oy))
    sw = max(1, int(shield.width * cfg['sx']))
    sh = max(1, int(shield.height * cfg['sy']))
    sc = shield.resize((sw, sh), Image.LANCZOS)
    # 护盾 origin 也是中心点，把它落到 (PX+dx, PY+dy)
    canvas.alpha_composite(sc, (int(PX + cfg['dx'] - shield_ox * cfg['sx']),
                                int(PY + cfg['dy'] - shield_oy * cfg['sy'])))
    return canvas, (ox, oy)


def flatten(im, bg=(238, 241, 246)):
    b = Image.new('RGBA', im.size, bg + (255,))
    b.alpha_composite(im)
    return b.convert('RGB')


def main():
    out = os.path.join(ROOT, 'output', 'kuafu_shield_preview.png')
    args = sys.argv[1:]
    if '--out' in args:
        out = args[args.index('--out') + 1]

    shield, sox, soy = first_frame(SHIELD)
    cases = [
        ('变异皮特·当前', 'spr_kuafu_boss_pete_idle', dict(dx=60, dy=-145, sx=2.0, sy=1.45)),
        ('变异皮特·修复后（待机）', 'spr_kuafu_boss_pete_idle', dict(dx=-101, dy=-134, sx=0.95, sy=1.05)),
        ('变异皮特·修复后（钢爪）', 'spr_kuafu_boss_pete_skill_3', dict(dx=-101, dy=-134, sx=0.95, sy=1.05)),
        ('变异朱莉·当前', 'spr_kuafu_boss_julie_idle', dict(dx=10, dy=-82, sx=1.8, sy=1.0)),
        ('变异朱莉·修复后（待机）', 'spr_kuafu_boss_julie_idle', dict(dx=-130, dy=-100, sx=1.05, sy=1.12)),
        ('变异朱莉·修复后（召唤）', 'spr_kuafu_boss_julie_skill_2', dict(dx=-130, dy=-100, sx=1.05, sy=1.12)),
    ]
    tiles = []
    for label, body, cfg in cases:
        im, _ = render(body, cfg, shield, sox, soy)
        tiles.append((label, cfg, im))

    # 裁掉透明边、放大，便于肉眼比对（护盾中心十字先记下再缩放）
    ZOOM = 1.6
    crops = []
    for label, cfg, im in tiles:
        bb = im.getbbox()
        pad = 30
        box = (max(0, bb[0] - pad), max(0, bb[1] - pad),
               min(im.width, bb[2] + pad), min(im.height, bb[3] + pad))
        sub = im.crop(box)
        marks = [(PX - box[0], PY - box[1], (220, 60, 60)),
                 (PX + cfg['dx'] - box[0], PY + cfg['dy'] - box[1], (30, 120, 220))]
        sub = sub.resize((int(sub.width * ZOOM), int(sub.height * ZOOM)), Image.LANCZOS)
        crops.append((label, cfg, sub, [(m[0] * ZOOM, m[1] * ZOOM, m[2]) for m in marks]))

    pad, label_h = 14, 44
    cell_w = max(c[2].width for c in crops)
    cell_h = max(c[2].height for c in crops)
    W = 3 * (cell_w + pad) + pad
    H = 2 * (cell_h + label_h + pad) + pad
    canvas = Image.new('RGB', (W, H), (250, 251, 253))
    d = ImageDraw.Draw(canvas)
    for i, (label, cfg, im, marks) in enumerate(crops):
        cx = pad + (i % 3) * (cell_w + pad)
        cy = pad + (i // 3) * (cell_h + label_h + pad)
        canvas.paste(flatten(im), (cx, cy + label_h))
        d.text((cx + 6, cy + 4), label, fill=(10, 10, 20))
        d.text((cx + 6, cy + 22),
               f"dx={cfg['dx']}  dy={cfg['dy']}  sx={cfg['sx']}  sy={cfg['sy']}",
               fill=(80, 88, 104))
        for mx, my, col in marks:
            d.line([(cx + mx - 10, cy + label_h + my), (cx + mx + 10, cy + label_h + my)], fill=col)
            d.line([(cx + mx, cy + label_h + my - 10), (cx + mx, cy + label_h + my + 10)], fill=col)
    canvas.save(out)
    print('saved', out, canvas.size)


if __name__ == '__main__':
    main()
