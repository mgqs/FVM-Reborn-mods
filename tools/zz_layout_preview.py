# -*- coding: utf-8 -*-
"""按 obj_zz_bg / obj_zz_shop_bg 的 Draw_0 逻辑，用 PIL 离线重绘一遍 1920×1080 画面。

用途：本机没有 GMS 运行时，靠这个脚本验证「代码里的坐标」和预览稿是否一致
（元素重叠、越界、文字压边都能一眼看出来）。数值必须与 GML 里的常量保持一致：
    zz_k = 1.5, zz_ox = 150, zz_oy = 0
改版式时两边一起改。

用法：python tools/zz_layout_preview.py  → output/_tmp/zz/gml_main.png / gml_result.png / gml_shop.png
"""
import io
import json
import os
import re

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPR = os.path.join(ROOT, 'sprites')
OUT = os.path.join(ROOT, 'output', '_tmp', 'zz')
FONT = r'C:/Windows/Fonts/msyh.ttc'

K, OX, OY = 1.5, 150, 0

_cache = {}


def sprite(name, frame=0):
    key = (name, frame)
    if key in _cache:
        return _cache[key]
    yy = os.path.join(SPR, name, name + '.yy')
    txt = io.open(yy, encoding='utf-8').read()
    d = json.loads(re.sub(r',(\s*[}\]])', r'\1', txt))
    guid = d['frames'][frame]['name']
    img = Image.open(os.path.join(SPR, name, guid + '.png')).convert('RGBA')
    _cache[key] = img
    return img


_origin = {}


def sprite_origin(name):
    """读 .yy 的 sequence.xorigin / yorigin（GML 的 sprite_get_xoffset）"""
    if name in _origin:
        return _origin[name]
    yy = os.path.join(SPR, name, name + '.yy')
    d = json.loads(re.sub(r',(\s*[}\]])', r'\1', io.open(yy, encoding='utf-8').read()))
    q = d['sequence']
    _origin[name] = (q['xorigin'], q['yorigin'])
    return _origin[name]


def blit_orig(canvas, name, x, y, scale=1.0):
    """按 sprite 原点绘制（等价于 draw_sprite_ext(spr, 0, x, y, scale, scale, ...)）"""
    art = sprite(name)
    ox, oy = sprite_origin(name)
    if scale != 1.0:
        art = art.resize((max(1, int(round(art.width * scale))), max(1, int(round(art.height * scale)))),
                         Image.LANCZOS)
    canvas.alpha_composite(art, (int(round(x - ox * scale)), int(round(y - oy * scale))))


def px(v):
    return OX + v * K


def py(v):
    return OY + v * K


def sz(v):
    return v * K


def blit(canvas, spr, x, y, w, h):
    im = spr.resize((max(1, int(round(sz(w)))), max(1, int(round(sz(h))))), Image.LANCZOS)
    canvas.alpha_composite(im, (int(round(px(x))), int(round(py(y)))))


def blit_center(canvas, spr, cx, cy, size):
    s = int(round(sz(size)))
    im = spr.resize((s, s), Image.LANCZOS)
    canvas.alpha_composite(im, (int(round(px(cx) - s / 2)), int(round(py(cy) - s / 2))))


def text(canvas, s, x, y, size, color, align='center'):
    f = ImageFont.truetype(FONT, int(round(size * K)))
    d = ImageDraw.Draw(canvas)
    w = d.textlength(s, font=f)
    gx, gy = px(x), py(y)
    if align == 'center':
        gx -= w / 2
    elif align == 'right':
        gx -= w
    d.text((gx, gy - size * K * 0.65), s, font=f, fill=color)


def wallet(canvas, iid, txt, right_x, cy, size, color):
    f = ImageFont.truetype(FONT, int(round(size * K)))
    d = ImageDraw.Draw(canvas)
    tw = d.textlength(txt, font=f)
    rx = px(right_x)
    icon(canvas, iid, (rx - tw - size * K * 0.65 - OX) / K, cy, size)
    d.text((rx - tw, py(cy) - size * K * 0.65), txt, font=f, fill=color)


def round_rect(canvas, x1, y1, x2, y2, rad, fill=None, outline=None, width=2):
    d = ImageDraw.Draw(canvas)
    box = [px(x1), py(y1), px(x2), py(y2)]
    d.rounded_rectangle(box, radius=rad * K, fill=fill, outline=outline, width=width)


MAT_FRAME = {
    'clover_1': 3, 'clover_2': 4, 'clover_3': 5, 'clover_4': 9,
    'clover_5': 19, 'clover_6': 20, 'clover_s': 21, 'clover_ss': 22,
    'zz_star': 23, 'magic_spices': 15, 'elf_spices': 16,
    'angel_spices': 17, 'saint_spices': 18,
    'natural_spices': 0, 'secret_spices': 1, 'royal_spices': 2,
}


def icon(canvas, iid, cx, cy, size):
    if iid == 'gold':
        blit_center(canvas, sprite('spr_zz_coin'), cx, cy, size)
    else:
        blit_center(canvas, sprite('spr_craft_material', MAT_FRAME[iid]), cx, cy, size)


CELL_IDS = ['clover_1', 'clover_2', 'clover_3', 'clover_4', 'clover_5', 'clover_6',
            'clover_s', 'clover_ss', 'zz_star', 'gold', 'clover_5', 'clover_1',
            'clover_3', 'clover_4', 'clover_6', 'clover_2', 'clover_s', 'gold']
CELL_SPR = ['spr_zz_cell_pink', 'spr_zz_cell_green', 'spr_zz_cell_blue',
            'spr_zz_cell_orange', 'spr_zz_cell_purple', 'spr_zz_cell_red']
GRID = [(c, 0) for c in range(7)] + [(0, 1), (6, 1), (0, 2), (6, 2)] + [(c, 3) for c in range(7)]


def base_scene(canvas):
    uy = -22          # 与 GML 的 zz_ui_dy 一致：机台整块上移
    bg = sprite('spr_zz_bg')
    s = max(1920 / bg.width, 1080 / bg.height)
    bg = bg.resize((int(bg.width * s), int(bg.height * s)), Image.LANCZOS)
    canvas.alpha_composite(bg, (int((1920 - bg.width) / 2), int((1080 - bg.height) / 2)))
    ov = Image.new('RGBA', canvas.size, (0, 0, 0, 90))
    canvas.alpha_composite(ov)

    blit(canvas, sprite('spr_zz_machine'), 90, 104 + uy, 900, 568)
    blit(canvas, sprite('spr_zz_title'), 456, 26, 168, 52)
    blit(canvas, sprite('spr_zz_tab_lucky_on'), 247, 212 + uy, 130, 38)
    text(canvas, '距离下次保底 剩余 50 次（下次：4级四叶草）', 624, 231 + uy, 13, (255, 255, 255))

    for i, (c, r) in enumerate(GRID):
        gx, gy = 267 + c * 78, 250 + uy + r * 80
        blit(canvas, sprite(CELL_SPR[i % 6]), gx, gy, 74, 74)
        icon(canvas, CELL_IDS[i], gx + 37, gy + 37, 56)

    round_rect(canvas, 345, 326 + uy, 731, 476 + uy, 14, fill=(0, 0, 0, 107), outline=(255, 206, 120))
    blit(canvas, sprite('spr_zz_treasure_cap'), 482, 334 + uy, 112, 29)
    for i, iid in enumerate(['clover_5', 'clover_6', 'clover_s', 'clover_ss']):
        icon(canvas, iid, 401 + i * 80, 414 + uy, 56)
    blit(canvas, sprite('spr_zz_btn_exshop'), 631, 332 + uy, 86, 32)

    for i, (spr, x, lab) in enumerate([('spr_zz_price_20000', 243, '1 抽'),
                                       ('spr_zz_price_100000', 443, '10 抽'),
                                       ('spr_zz_price_1000000', 643, '50 抽')]):
        blit(canvas, sprite(spr), x, 603 + uy, 190, 61)
        text(canvas, lab, x + 95, 585 + uy, 13, (255, 235, 120))

    blit(canvas, sprite('spr_zz_side_lucky_on'), 956, 266 + uy, 116, 56)
    blit(canvas, sprite('spr_zz_side_gift_off'), 956, 332 + uy, 116, 56)

    wallet(canvas, 'gold', '1,000,000', 985, 32, 18, (255, 215, 90))
    wallet(canvas, 'zz_star', '0', 1058, 32, 18, (120, 230, 255))

    blit(canvas, sprite('spr_zz_btn_close'), 1000, 600 + uy, 55, 55)
    text(canvas, '消耗金币购买四叶草，就有机会获得马年生肖卡等稀有道具',
         540, 690, 13, (201, 180, 240))


def draw_result(canvas, items, cost, count, star=18):
    ov = Image.new('RGBA', canvas.size, (0, 0, 0, 160))
    canvas.alpha_composite(ov)
    blit(canvas, sprite('spr_zz_panel'), 210, 110, 660, 500)
    blit(canvas, sprite('spr_zz_congrats'), 396, 112, 288, 78)
    blit(canvas, sprite('spr_zz_btn_close'), 792, 126, 52, 52)

    text(canvas, '本次消耗', 470, 210, 12, (255, 255, 255))
    round_rect(canvas, 442, 222, 498, 278, 10, fill=(230, 220, 250))
    icon(canvas, 'gold', 470, 250, 44)
    text(canvas, '%d 金币（%d抽）' % (cost, count), 470, 294, 12, (74, 59, 138))

    text(canvas, '获得幸运星', 610, 210, 12, (255, 255, 255))
    round_rect(canvas, 582, 222, 638, 278, 10, fill=(230, 220, 250))
    icon(canvas, 'zz_star', 610, 250, 44)
    text(canvas, '持有 %d' % star, 610, 294, 12, (74, 59, 138))

    n = len(items)
    per = n if n <= 8 else -(-n // 2)
    step = min(74, 520 / per)
    isz = min(56, step - 16)
    for k, it in enumerate(items):
        row, col = k // per, k % per
        cnt = min(n - row * per, per)
        x0 = 540 - (cnt * step) / 2 + step / 2
        cx, cy = x0 + col * step, 352 + row * 78
        round_rect(canvas, cx - 31, cy - 31, cx + 31, cy + 31, 10, fill=(246, 240, 255))
        if it.get('pity'):
            round_rect(canvas, cx - 31, cy - 31, cx + 31, cy + 31, 10, outline=(255, 140, 60), width=3)
        icon(canvas, it['id'], cx, cy - 2, isz)
        text(canvas, '×%d' % it['qty'], cx, cy + 39, 10, (255, 255, 255))
        text(canvas, '×%d' % it['qty'], cx, cy + 39, 10, (96, 52, 10))

    for i, (spr, x) in enumerate([('spr_zz_btn_again1', 305), ('spr_zz_btn_again10', 467),
                                  ('spr_zz_btn_again50', 629)]):
        blit(canvas, sprite(spr), x, 516, 146, 50)


# ── 兑换页（版式对齐原版「兑换商店」）──────────────────────────────
PANEL_X, PANEL_Y, PANEL_S = 960, 540, 0.9
CARD_W, CARD_H, COL_GAP, ROW_GAP = 380, 162, 410, 200
GRID_CX, GRID_CY = 960, 552

# (id, 数量, 消耗幸运星, 是否卡片)
SHOP_ITEMS = [('yanyantu', 1, 36, True), ('wugushe', 1, 36, True), ('xuanfengniu', 1, 36, True),
              ('starrabbit', 1, 54, True), ('magic_chicken', 1, 66, True), ('fashishe', 1, 66, True),
              ('zhanqima', 1, 88, True), ('baibianshe', 1, 108, True),
              ('clover_5', 3, 2, False), ('clover_6', 3, 4, False),
              ('clover_s', 3, 8, False), ('clover_ss', 3, 16, False)]
SHOP_NAMES = {'yanyantu': '炎焱兔', 'wugushe': '巫蛊蛇', 'xuanfengniu': '旋风牛',
              'starrabbit': '星星兔', 'magic_chicken': '幻幻鸡', 'fashishe': '法师蛇',
              'zhanqima': '战旗马', 'baibianshe': '百变蛇',
              'clover_5': '5级四叶草', 'clover_6': '6级四叶草',
              'clover_s': 'S级四叶草', 'clover_ss': 'SS级四叶草'}

# 跨服白银页新上的香料（一次 200 个）
CS_SPICES = [('royal_spices', 200, 400, '皇室香料'), ('magic_spices', 200, 600, '魔幻香料'),
             ('elf_spices', 200, 800, '精灵香料'), ('angel_spices', 200, 1000, '天使香料'),
             ('saint_spices', 200, 1200, '圣灵香料')]
def pan_sx(v):
    return PANEL_X + (v - 940) * PANEL_S


def pan_sy(v):
    return PANEL_Y + (v - 542) * PANEL_S


def blit_at(canvas, spr, cx, cy, scale):
    im = spr.resize((max(1, int(round(spr.width * scale))), max(1, int(round(spr.height * scale)))),
                    Image.LANCZOS)
    canvas.alpha_composite(im, (int(round(cx - im.width / 2)), int(round(cy - im.height / 2))))


def stext(canvas, s, x, y, size, color, align='center'):
    """屏幕像素字号（不走 K）"""
    f = ImageFont.truetype(FONT, int(round(size)))
    d = ImageDraw.Draw(canvas)
    w = d.textlength(s, font=f)
    if align == 'center':
        x -= w / 2
    elif align == 'right':
        x -= w
    d.text((x, y - size * 0.62), s, font=f, fill=color)


def sicon(canvas, iid, cx, cy, size):
    if iid == 'gold':
        spr = sprite('spr_zz_coin')
    else:
        spr = sprite('spr_craft_material', MAT_FRAME[iid])
    blit_at(canvas, spr, cx, cy, size / spr.width)


COL_X = [342, 753, 1164, 1575]          # 面板中心 -618 + 411*col
CS_COL_X = [342, 753, 1164, 1575]       # 跨服白银页同一套列坐标
CS_ROW_Y = [292, 457, 622, 787]         # 跨服白银页 y - 248 + 165*row
ROW_Y = [350, 515, 680, 845]            # 面板中心 -190 + 165*row（4×4 = 16 格固定绘制）
BUY_DX, BUY_DY, BUY_S = 77, 60, 1.8     # spr_shop_buy_btn：格心 +77/+60、1.8 倍
PG_PREV, PG_NEXT, PG_TXT, PG_S = (1245, 975), (1445, 975), (1347, 975), 1.8


def blit_flip(canvas, spr, cx, cy, scale):
    """image_xscale = -1 的横向翻转（「下一页」箭头）"""
    im = spr.resize((max(1, int(round(spr.width * scale))), max(1, int(round(spr.height * scale)))),
                    Image.LANCZOS)
    im = im.transpose(Image.FLIP_LEFT_RIGHT)
    canvas.alpha_composite(im, (int(round(cx - im.width / 2)), int(round(cy - im.height / 2))))


def draw_shop(canvas, star=26):
    """复刻 obj_zz_shop_bg/Draw_0：商城底板 + 16 格 + 购买按钮 + 翻页 + 右上角关闭"""
    ov = Image.new('RGBA', canvas.size, (0, 0, 0, int(255 * 0.5)))
    canvas.alpha_composite(ov)

    blit_at(canvas, sprite('spr_shop_bg'), PANEL_X, PANEL_Y, PANEL_S)
    blit_at(canvas, sprite('spr_shop_bg_2'), PANEL_X, PANEL_Y + 58, 1.8)

    # 16 格固定绘制（空格子也画）
    for s_i in range(16):
        blit_at(canvas, sprite('spr_shop_goods_bg'), COL_X[s_i % 4], ROW_Y[s_i // 4], 1.8)

    for i, (iid, qty, cost, is_card) in enumerate(SHOP_ITEMS):
        cx, cy = COL_X[i % 4], ROW_Y[i // 4]
        if is_card:
            blit_orig(canvas, 'spr_slot', cx - 123, cy, 0.33)
            blit_orig(canvas, 'spr_' + iid, cx - 123, cy + 25, 1.0)
            stext(canvas, SHOP_NAMES[iid], cx + 79, cy - 44, 17, (0, 0, 0))
        else:
            sicon(canvas, iid, cx - 123, cy, 72 if iid.startswith('clover_') else 144)
            stext(canvas, SHOP_NAMES[iid], cx + 52, cy - 44, 17, (0, 0, 0))
            stext(canvas, '×%d' % qty, cx + 186, cy - 44, 16, (140, 78, 20), 'right')
        # 「消耗 N」+ 星 作为一个整体居中于消耗条（条中心 = 格心 +79）
        lab = '消耗 %d' % cost
        tw = ImageDraw.Draw(canvas).textlength(lab, font=ImageFont.truetype(FONT, 18))
        gap, ico = 10, 34
        x0 = cx + 77 - (tw + gap + ico) / 2
        stext(canvas, lab, x0, cy - 1, 18, (255, 255, 255), 'left')
        sicon(canvas, 'zz_star', x0 + tw + gap + ico / 2, cy - 1, ico)
        blit_at(canvas, sprite('spr_shop_buy_btn'), cx + BUY_DX, cy + BUY_DY, BUY_S)

    # 底部余额条
    bx1, by1, bx2, by2 = pan_sx(0), pan_sy(998), pan_sx(450), pan_sy(1054)
    ImageDraw.Draw(canvas).rounded_rectangle([bx1, by1, bx2, by2], radius=12, fill=(3, 43, 80))
    bcy = (by1 + by2) / 2
    # 「幸运星 + 图标 + 数量」整组贴左，图标与数量直接跟在文字后面
    lw = ImageDraw.Draw(canvas).textlength('幸运星', font=ImageFont.truetype(FONT, 24))
    lx = bx1 + 22
    stext(canvas, '幸运星', lx, bcy, 24, (150, 210, 240), 'left')
    ib = 40
    ix = lx + lw + 12 + ib / 2
    sicon(canvas, 'zz_star', ix, bcy, ib)
    stext(canvas, str(star), ix + ib / 2 + 6, bcy, 26, (255, 232, 140), 'left')

    # 翻页箭头 + 页码
    blit_at(canvas, sprite('spr_shop_page_btn'), PG_PREV[0], PG_PREV[1], PG_S)
    blit_flip(canvas, sprite('spr_shop_page_btn'), PG_NEXT[0], PG_NEXT[1], PG_S)
    stext(canvas, '1/1', PG_TXT[0], PG_TXT[1], 24, (255, 255, 255))

    # 右上角关闭
    blit_at(canvas, sprite('spr_closemenu_btn'), 1760, 110, 1.8)


def draw_confirm(canvas, txt='确定以36幸运星兑换炎炎兔吗？'):
    """复刻 obj_zz_buy_confirm/Draw_0：spr_battle_escape_menu 1.5 倍 + spr_common_button 1.35 倍"""
    ov = Image.new('RGBA', canvas.size, (0, 0, 0, int(255 * 0.5)))
    canvas.alpha_composite(ov)
    blit_at(canvas, sprite('spr_battle_escape_menu'), 960, 540, 1.5)
    stext(canvas, '兑换确认', 960, 428, 16, (255, 255, 255))
    stext(canvas, txt, 960, 530, 16, (255, 255, 255))
    # spr_common_button 的 PNG 是 156×66（.yy 写的是 78×33），0.75 倍 = 117×50，
    # 与商城确认框同写法：坐标即按钮中心
    for off, lab in ((-80, '确定'), (80, '取消')):
        im = sprite('spr_common_button').resize((int(round(156 * 0.75)), int(round(66 * 0.75))),
                                                Image.LANCZOS)
        canvas.alpha_composite(im, (int(round(960 + off - im.width / 2)), int(round(610 - im.height / 2))))
        stext(canvas, lab, 960 + off, 610, 16, (255, 255, 255))


def draw_cs_spices(canvas):
    """复刻 obj_cross_server_shop/Draw_0 的白银页前 5 格（= 新上架的香料），验证卡片内部排版"""
    ImageDraw.Draw(canvas).rectangle([0, 0, 1920, 1080], fill=(37, 105, 170))
    for i, (iid, qty, cost, name) in enumerate(CS_SPICES):
        gx = CS_COL_X[i % 4]
        gy = CS_ROW_Y[i // 4]
        blit_at(canvas, sprite('spr_shop_goods_bg'), gx, gy, 1.8)
        sicon(canvas, iid, gx - 122, gy - 2, 124)
        stext(canvas, name, gx + 56, gy - 46, 17, (0, 0, 0))
        stext(canvas, '×%d' % qty, gx + 186, gy - 46, 16, (140, 78, 20), 'right')
        stext(canvas, str(cost), gx + 69, gy + 2, 20, (255, 232, 140))
        blit_at(canvas, sprite('spr_mod_cs_silver_medal'), gx + 167, gy + 1, 0.8)
        blit_at(canvas, sprite('spr_shop_buy_btn'), gx + 77, gy + 60, 1.8)
    stext(canvas, '跨服白银页 · 香料（400 / 600 / 800 / 1000 / 1200 白银勋章，各 200 个）',
          960, 1000, 24, (255, 255, 255))


def main():
    os.makedirs(OUT, exist_ok=True)

    m = Image.new('RGBA', (1920, 1080), (16, 12, 28, 255))
    base_scene(m)
    m.convert('RGB').save(os.path.join(OUT, 'gml_main.png'))

    r = Image.new('RGBA', (1920, 1080), (16, 12, 28, 255))
    base_scene(r)
    draw_result(r, [
        {'id': 'clover_1', 'qty': 1}, {'id': 'gold', 'qty': 5000}, {'id': 'clover_3', 'qty': 1},
        {'id': 'clover_2', 'qty': 1}, {'id': 'clover_5', 'qty': 1}, {'id': 'clover_1', 'qty': 1},
        {'id': 'clover_4', 'qty': 1}, {'id': 'gold', 'qty': 10000}, {'id': 'clover_2', 'qty': 1},
        {'id': 'zz_star', 'qty': 5, 'pity': True},
    ], 100000, 10)
    r.convert('RGB').save(os.path.join(OUT, 'gml_result.png'))

    s = Image.new('RGBA', (1920, 1080), (16, 12, 28, 255))
    base_scene(s)
    draw_shop(s)
    s.convert('RGB').save(os.path.join(OUT, 'gml_shop.png'))

    d = Image.new('RGBA', (1920, 1080), (16, 12, 28, 255))
    base_scene(d)
    draw_shop(d)
    draw_confirm(d)
    d.convert('RGB').save(os.path.join(OUT, 'gml_confirm.png'))

    c = Image.new('RGBA', (1920, 1080), (37, 105, 170, 255))
    draw_cs_spices(c)
    c.convert('RGB').save(os.path.join(OUT, 'gml_cs_spices.png'))
    print('输出:', OUT)


if __name__ == '__main__':
    main()
