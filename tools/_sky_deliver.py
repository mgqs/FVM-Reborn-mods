# -*- coding: utf-8 -*-
"""交付预览：8 关成品底图 + 单层流动云的运行时节奏。

底图 = sprites/spr_mengyantiankong_0..7（1109×597，天空背景图打底，col0-1 画死云墙 + 绿星障碍）
绘制 = objects/obj_battle/Draw_0.gml 的单画 + 边缘拉伸补边
云   = datafiles JSON：no_resident / spawn_interval 8 / fade_col 2 / interval 30
"""
import glob
import json
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
LEVELS = os.path.join(ROOT, 'datafiles', 'level_data', 'cross')
GW, GH = 1920, 1080
GOX, GOY, CW, CH = 695, 228, 107, 116
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
ROWS, COLS = 7, 9
NAMES = ['天空静夜', '天空蒙雾', '天空薄雾', '天空迷雾', '天空浓雾', '天空重雾', '天空夜雾', '天空终雾']


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def cc(c, r):
    return GOX + c * CW + CW / 2, GOY + r * CH + CH / 2


def build_bg(idx):
    p = glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_%d' % idx, '*.png'))[0]
    art = Image.open(p).convert('RGBA')
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    w, h = int(round(art.width * GSX)), int(round(art.height * GSY))
    x0, y0 = int(round(GX)), int(round(GY))
    canvas.paste(art.crop((0, 0, 1, art.height)).resize((x0, h), Image.NEAREST).convert('RGB'), (0, y0))
    if x0 + w < GW:
        canvas.paste(art.crop((art.width - 1, 0, art.width, art.height))
                     .resize((GW - x0 - w, h), Image.NEAREST).convert('RGB'), (x0 + w, y0))
    canvas.paste(art.crop((0, 0, art.width, 1)).resize((w, y0), Image.NEAREST).convert('RGB'), (x0, 0))
    if y0 + h < GH:
        canvas.paste(art.crop((0, art.height - 1, art.width, art.height))
                     .resize((w, GH - y0 - h), Image.NEAREST).convert('RGB'), (x0, y0 + h))
    canvas.paste(art.convert('RGB').resize((w, h), Image.LANCZOS), (x0, y0))
    return canvas


def load_ev(idx):
    t = open(os.path.join(LEVELS, 'nightmare_sky-%d.json' % idx), encoding='utf-8').read().rstrip('\x00')
    return json.loads(t)['events'][0]


FRAMES = [Image.open(p).convert('RGBA') for p in
          sorted(glob.glob(os.path.join(ROOT, 'sprites', 'spr_cloud_night', '*.png')))][:2]
SCALED = [f.resize((int(round(f.width * 1.8)), int(round(f.height * 1.8))), Image.LANCZOS)
          for f in FRAMES]


class Sim:
    def __init__(self, ev):
        self.res = not ev.get('no_resident', False)
        self.spawn = max(60, round(ev['spawn_interval'] * 60))
        self.fade_x = cc(ev.get('fade_col', 1), 0)[0]
        self.rows = ev['cloud_rows']
        self.items, self.count, self.t = [], 0, 0

    def step(self):
        self.t += 1
        if self.t == 1 and self.res:
            for c in range(2, COLS):
                for r in range(ROWS):
                    if r + 1 in self.rows:
                        x, y = cc(c, r)
                        self.items.append([x, y - 10, 1.0, self.count % 2])
                self.count += 1
        if self.t % self.spawn == 1:
            for r in range(ROWS):
                if r + 1 in self.rows:
                    x, y = cc(9, r)
                    self.items.append([x, y - 10, 0.0, self.count % 2])
            self.count += 1
        alive = []
        for it in self.items:
            it[0] -= 0.25
            if it[0] > self.fade_x:
                it[2] = min(1.0, it[2] + 0.1)
            else:
                it[2] -= 0.1
                if it[2] <= 0:
                    continue
            alive.append(it)
        self.items = alive

    def draw(self, canvas):
        for x, y, a, idx in self.items:
            if a <= 0.004:
                continue
            spr = SCALED[idx % len(SCALED)]
            if a < 1:
                spr = spr.copy()
                spr.putalpha(spr.split()[3].point(lambda v: int(v * a)))
            canvas.paste(spr, (int(round(x - spr.width / 2)), int(round(y - spr.height / 2))), spr)
        return canvas


def grid(img):
    out = img.copy()
    d = ImageDraw.Draw(out, 'RGBA')
    for c in range(COLS + 1):
        x = GOX + c * CW
        d.line([(x, GOY), (x, GOY + ROWS * CH)], fill=(0, 255, 255, 38), width=1)
    for r in range(ROWS + 1):
        y = GOY + r * CH
        d.line([(GOX, y), (GOX + COLS * CW, y)], fill=(0, 255, 255, 38), width=1)
    return out


# ---- 1. 8 关静止成品 ----
bases = []
for n in range(8):
    b = build_bg(n)
    b.save(os.path.join(OUT, 'deliver_level_%d.png' % n))
    bases.append(b)

TW, TH = GW // 4, GH // 4
sheet = Image.new('RGB', (TW * 4 + 20, TH * 2 + 128), (18, 18, 24))
d = ImageDraw.Draw(sheet)
d.text((10, 8), '跨服·梦魇天空　8 关成品底图｜底层=天空背景图，最左两列逐格画云+绿星障碍',
       font=fnt(26), fill=(255, 255, 255))
d.text((10, 42), 'col2-8 已清空：关卡开局不再满屏是云，只剩从最右侧飘入的那一层（单层可移动云）',
       font=fnt(20), fill=(150, 220, 255))
for n in range(8):
    x = 6 + (n % 4) * (TW + 4)
    y = 76 + (n // 4) * (TH + 26)
    sheet.paste(bases[n].resize((TW, TH), Image.LANCZOS), (x, y))
    d.text((x + 5, y + 5), '%d %s' % (n, NAMES[n]), font=fnt(18), fill=(255, 235, 150))
sheet.save(os.path.join(OUT, 'deliver_8levels.png'))

# ---- 2. 第 4 关的时间线（该关障碍最多，最能看清云不压障碍）----
TIMES = (1, 600, 1800, 3600, 5400)
sim = Sim(load_ev(4))
tl = {}
for t in range(1, max(TIMES) + 1):
    sim.step()
    if t in TIMES:
        tl[t] = (len(sim.items), sim.draw(bases[4].copy()))
tw2, th2 = GW // 5, GH // 5
tsheet = Image.new('RGB', (tw2 * len(TIMES) + (len(TIMES) + 1) * 5, th2 + 92), (18, 18, 24))
d = ImageDraw.Draw(tsheet)
d.text((10, 8), '第 4 关「天空浓雾」单层云的时间线（1 秒 → 90 秒）', font=fnt(24), fill=(255, 255, 255))
d.text((10, 40), '云从最右侧成排飘入，走到第 3 列淡出；始终只有一条云带在动，不会再叠出第二层',
       font=fnt(19), fill=(150, 220, 255))
for i, t in enumerate(TIMES):
    cnt, im = tl[t]
    x = 5 + i * (tw2 + 5)
    tsheet.paste(im.resize((tw2, th2), Image.LANCZOS), (x, 70))
    d.text((x + 4, 72), '%ds / %d 朵' % (t, cnt), font=fnt(16), fill=(150, 255, 200))
tsheet.save(os.path.join(OUT, 'deliver_timeline.png'))

print('云数 @1/10/30/60/90s =', [tl[t][0] for t in TIMES])
print('输出 deliver_8levels.png / deliver_timeline.png / deliver_level_0..7.png')
