# -*- coding: utf-8 -*-
"""梦魇天空 v5 云层方案对比（照棉花糖天空的设置方法）。

核心洞察：
- 棉花糖天空（cotton_candy_sky_night）走硬编码分支 obj_event_manager/Step_0.gml:327-362：
    ① 开局 col2..8 常驻铺满 obj_cloud（alpha=1），这批云会一直左飘、飘到 col1 淡出销毁；
    ② 每 480 帧（8 秒）从 col9 补一排。
  它底图里的云画死在左右边框（x<600 与 x>1400），流动云只存在于 col2..8，
  到 col1 格心就淡出，所以**永远不与底图云重叠** —— 观感就是「一层」。
- 梦魇天空现在的毛病：spawn_interval = 5 秒，飘入云要 56 秒才走完全程，
  同屏堆积 11 排（77 朵）盖满 col2..8，最后几排还压到底图 col0-1 的固定云墙上 → 看着就是两层。
"""
import glob
import os

from PIL import Image, ImageDraw, ImageFont

ROOT = r'D:\gameProject\FVM-Reborn-mod'
OUT = os.path.join(ROOT, 'output', '梦魇天空预览')
GW, GH = 1920, 1080
GOX, GOY, CW, CH = 695, 228, 107, 116
GX, GY, GSX, GSY = 13.2, 12.39, 1.7833, 1.78
ROWS, COLS = 7, 9
CLOUD_ROWS = list(range(1, 8))


def fnt(sz):
    for nm in ('msyhbd.ttc', 'msyh.ttc', 'simhei.ttf'):
        p = os.path.join(r'C:\Windows\Fonts', nm)
        if os.path.exists(p):
            return ImageFont.truetype(p, sz)
    return ImageFont.load_default()


def cc(c, r):
    return GOX + c * CW + CW / 2, GOY + r * CH + CH / 2


def compose_bg(art):
    """修好后的 Draw_0：单画 + 边缘 1 像素拉伸补边。"""
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    w, h = int(round(art.width * GSX)), int(round(art.height * GSY))
    x0, y0 = int(round(GX)), int(round(GY))
    canvas.paste(art.crop((0, 0, 1, art.height)).resize((x0, h), Image.NEAREST).convert('RGB'), (0, y0))
    rw = GW - (x0 + w)
    if rw > 0:
        canvas.paste(art.crop((art.width - 1, 0, art.width, art.height))
                     .resize((rw, h), Image.NEAREST).convert('RGB'), (x0 + w, y0))
    canvas.paste(art.crop((0, 0, art.width, 1)).resize((w, y0), Image.NEAREST).convert('RGB'), (x0, 0))
    bh = GH - (y0 + h)
    if bh > 0:
        canvas.paste(art.crop((0, art.height - 1, art.width, art.height))
                     .resize((w, bh), Image.NEAREST).convert('RGB'), (x0, y0 + h))
    canvas.paste(art.convert('RGB').resize((w, h), Image.LANCZOS), (x0, y0))
    return canvas


FRAMES = [Image.open(p).convert('RGBA') for p in
          sorted(glob.glob(os.path.join(ROOT, 'sprites', 'spr_cloud_night', '*.png')))][:2]
SCALED = []
for f in FRAMES:
    w, h = int(round(f.width * 1.8)), int(round(f.height * 1.8))
    SCALED.append(f.resize((w, h), Image.LANCZOS))


class Sim:
    """resident=开局是否铺 col2..8；interval=补排秒数（None=不补）；fade_col=淡出起始列。"""

    def __init__(self, resident, interval, fade_col=1):
        self.resident = resident
        self.spawn = None if not interval else max(60, round(interval * 60))
        self.fade_x = cc(fade_col, 0)[0]
        self.items, self.count, self.t = [], 0, 0

    def step(self):
        self.t += 1
        if self.t == 1 and self.resident:
            for c in range(2, COLS):
                for r in range(ROWS):
                    if r + 1 in CLOUD_ROWS:
                        x, y = cc(c, r)
                        self.items.append([x, y - 10, 1.0, self.count % 2])
                self.count += 1
        if self.spawn and self.t % self.spawn == 1:
            for r in range(ROWS):
                if r + 1 in CLOUD_ROWS:
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


PLANS = [
    ('P0', '现状 no_resident + 5秒补排 + 淡出于col1', True, 5, 1),
    ('P1', '棉花糖原法：常驻col2-8 + 8秒补排', False, 8, 1),
    ('P2', 'no_resident + 8秒补排 + 淡出于col1', True, 8, 1),
    ('P3', 'no_resident + 8秒补排 + 淡出于col2', True, 8, 2),
    ('P4', 'no_resident + 12秒补排 + 淡出于col2', True, 12, 2),
]
TIMES = (1, 600, 1800, 3600, 7200)   # 1s / 10s / 30s / 60s / 120s

art = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_3', '*.png'))[0]).convert('RGBA')
base = compose_bg(art)

cells, counts_all = [], []
for key, label, _, iv, fc in PLANS:
    sim = Sim(False if key != 'P1' else True, iv, fc)
    # P0 = 现在的实际配置：no_resident=true + spawn_interval 5 + fade col1
    if key == 'P0':
        sim = Sim(False, 5, 1)
    shots, cnts = {}, []
    for t in range(1, max(TIMES) + 1):
        sim.step()
        if t in TIMES:
            shots[t] = sim.draw(base.copy())
            cnts.append(len(sim.items))
    cells.append((key, label, shots))
    counts_all.append(cnts)
    print('%-3s %-40s 云数@1/10/30/60/120s = %s' % (key, label, cnts))

TW, TH = GW // 5, GH // 5
sheet = Image.new('RGB', (TW * len(TIMES) + (len(TIMES) + 1) * 6,
                          (TH + 30) * len(PLANS) + 62), (20, 20, 26))
d = ImageDraw.Draw(sheet)
d.text((10, 8), '梦魇天空 v5 云层方案（照棉花糖天空的设置方法）｜列＝1秒 / 10秒 / 30秒 / 60秒 / 120秒',
       font=fnt(24), fill=(255, 255, 255))
d.text((10, 36), '每格右上角是当场存活云朵数；P1 就是棉花糖天空的真实节奏（开局满屏→2分钟内自然走空→只剩一条补排带）',
       font=fnt(19), fill=(150, 220, 255))
for row, ((key, label, shots), cnts) in enumerate(zip(cells, counts_all)):
    y = 62 + row * (TH + 30)
    d.text((10, y), '%s  %s' % (key, label), font=fnt(20), fill=(255, 220, 130))
    for col, t in enumerate(TIMES):
        x = 6 + col * (TW + 6)
        sheet.paste(shots[t].resize((TW, TH), Image.LANCZOS), (x, y + 24))
        d.text((x + 4, y + 26), '%ds/%d朵' % (t, cnts[col]), font=fnt(15), fill=(150, 255, 200))
sheet.save(os.path.join(OUT, 'v5_overview.png'))
print('输出 v5_overview.png', sheet.size)
