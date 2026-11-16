# -*- coding: utf-8 -*-
"""梦魇天空 v6 预览：按「棉花糖天空的设置方法」落地后的真实观感。

已落地的引擎/数据事实（本脚本逐条复刻）：
- 底图：sprites/spr_mengyantiankong_N，1109×597，col0-1 画死云墙 + 绿星障碍，col2-8 是干净天空
- 绘制：objects/obj_battle/Draw_0.gml 已改为「单画 + 边缘1像素拉伸补边」（不再 cover 兜底重影）
- 云事件：datafiles/level_data/cross/nightmare_sky-N.json
    spawn_interval = 8 秒（= 棉花糖的 480 帧）
    常驻 col2..8（与棉花糖一致）
    fade_col = 2（流动云飘到第 3 列格心即淡出，不会压到底图 col0-1 的云墙）
- 运动：obj_cloud/Step_0.gml  x -= 0.25，过 fade_col 格心后 alpha -= 0.1 并销毁
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


def compose_bg(art, double=False):
    canvas = Image.new('RGB', (GW, GH), (11, 7, 21))
    w, h = int(round(art.width * GSX)), int(round(art.height * GSY))
    x0, y0 = int(round(GX)), int(round(GY))
    if double:
        cover = max(GW / art.width, GH / art.height)
        cw, ch = int(round(art.width * cover)), int(round(art.height * cover))
        canvas.paste(art.convert('RGB').resize((cw, ch), Image.LANCZOS),
                     (int(round((GW - cw) * 0.5)), int(round((GH - ch) * 0.5))))
    else:
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
SCALED = [f.resize((int(round(f.width * 1.8)), int(round(f.height * 1.8))), Image.LANCZOS)
          for f in FRAMES]


class Sim:
    def __init__(self, resident, interval_sec, fade_col):
        self.resident = resident
        self.spawn = max(60, round(interval_sec * 60))
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
        if self.t % self.spawn == 1:
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


def grid(img):
    out = img.copy()
    d = ImageDraw.Draw(out, 'RGBA')
    for c in range(COLS + 1):
        x = GOX + c * CW
        d.line([(x, GOY), (x, GOY + ROWS * CH)], fill=(0, 255, 255, 42), width=1)
    for r in range(ROWS + 1):
        y = GOY + r * CH
        d.line([(GOX, y), (GOX + COLS * CW, y)], fill=(0, 255, 255, 42), width=1)
    return out


art = Image.open(glob.glob(os.path.join(ROOT, 'sprites', 'spr_mengyantiankong_3', '*.png'))[0]).convert('RGBA')
base = compose_bg(art)

# ---- 主图：落地后的真实节奏（4 个时刻全屏）----
TIMES = (1, 300, 1200, 3600)
sim = Sim(False, 8, 2)
shots = {}
for t in range(1, max(TIMES) + 1):
    sim.step()
    if t in TIMES:
        shots[t] = (len(sim.items), sim.draw(base.copy()))
        grid(shots[t][1]).save(os.path.join(OUT, 'v6_applied_%ds.png' % t))

# ---- 对比：修好双画但沿用旧的 5 秒 + 淡出于 col1（= 用户看到的「两层云」）----
sim_old = Sim(True, 5, 1)
old_at = {}
for t in range(1, 3601):
    sim_old.step()
    if t == 1200:
        old_at[t] = (len(sim_old.items), sim_old.draw(compose_bg(art, True).copy()))

TW, TH = GW // 2, GH // 2
sheet = Image.new('RGB', (TW * 2 + 24, TH * 2 + 132), (20, 20, 26))
d = ImageDraw.Draw(sheet, 'RGBA')
d.text((10, 8), '梦魇天空 v6｜按棉花糖天空的设置方法落地后的真实观感（底图=新美术，Draw_0 单画）',
       font=fnt(26), fill=(255, 255, 255))
d.text((10, 42), '上排：落地后  开局 / 5 秒 / 20 秒 / 60 秒　　下排：同样是开局满屏云，但旧的 5 秒+淡出于col1 会叠成一团',
       font=fnt(20), fill=(160, 220, 255))
xs = [12, TW + 20]
y0 = 76
for i, t in enumerate(TIMES):
    cnt, im = shots[t]
    p = os.path.join(OUT, 'v6_applied_%ds.png' % t)
    if i < 2:
        sheet.paste(Image.open(p).resize((TW, TH), Image.LANCZOS), (xs[i], y0))
        d.text((xs[i] + 6, y0 + 6), '落地后 %ds／%d 朵' % (t, cnt), font=fnt(19), fill=(150, 255, 200))
    else:
        sheet.paste(Image.open(p).resize((TW, TH), Image.LANCZOS), (xs[i - 2], y0 + TH + 12))
        d.text((xs[i - 2] + 6, y0 + TH + 18), '落地后 %ds／%d 朵' % (t, cnt), font=fnt(19), fill=(150, 255, 200))
sheet.save(os.path.join(OUT, 'v6_applied_overview.png'))

# ---- 旧配置 vs 新配置：同一时刻 20 秒的并排 ----
sim_a = Sim(True, 5, 1)
sim_b = Sim(False, 8, 2)
a = b = None
for t in range(1, 1201):
    sim_a.step()
    sim_b.step()
    if t == 1200:
        a = sim_a.draw(compose_bg(art, True).copy())
        b = sim_b.draw(base.copy())
cmp_img = Image.new('RGB', (TW * 2 + 24, TH + 74), (20, 20, 26))
d = ImageDraw.Draw(cmp_img)
cmp_img.paste(a.resize((TW, TH), Image.LANCZOS), (0, 70))
cmp_img.paste(b.resize((TW, TH), Image.LANCZOS), (TW + 24, 70))
d.text((10, 8), '开局 20 秒时：左＝旧配置（双画 + 5秒补排 + 淡出于col1）＝用户说的「两层云」',
       font=fnt(22), fill=(255, 170, 120))
d.text((10, 38), '右＝新配置（单画 + 8秒补排 + 淡出于col2）＝一层云从左往右流过，不压底图云墙',
       font=fnt(22), fill=(140, 255, 170))
cmp_img.save(os.path.join(OUT, 'v6_old_vs_new.png'))

print('落地后云数 @1/5/20/60s =', [shots[t][0] for t in TIMES])
print('输出 v6_applied_overview.png / v6_old_vs_new.png / v6_applied_*s.png')
