# -*- coding: utf-8 -*-
"""生成「金马盛典」转转活动所需的 spr_zz_* 精灵。

源图：
  · C:/Users/18203/Desktop/转转/images/*.png        （TDNewYearActivityUI.swf 拆包位图）
  · C:/Users/18203/Desktop/转转/enter/116.png       （主城入口图标）
  · output/zz_preview/assets/price_*.png            （擦字重排后的金币按钮）
  · output/zz_preview/assets/btn_again50.png        （「再来五十次」）

所有源图先按游戏内目标尺寸 LANCZOS 放大，再写进 sprites/ 与 folders/精灵/mod.yy，
这样运行时 `draw_sprite_ext` 的缩放恒等于 1，文字不会糊。

幂等：同名精灵会整目录重建（build() 内部 shutil.rmtree）。
用法：python tools/make_zz_sprites.py
"""
import os
import sys
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_multi_frame_sprite import build  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMG = r"C:/Users/18203/Desktop/转转/images"
ENTER = r"C:/Users/18203/Desktop/转转/enter/116.png"
PRE = os.path.join(ROOT, 'output', 'zz_preview', 'assets')
TMP = os.path.join(ROOT, 'output', '_tmp', 'zz', 'spr_src')

# (精灵名, 源路径, 目标宽, 目标高)
JOBS = [
    # ── 场景 ──
    ('spr_zz_bg',           os.path.join(IMG, '667.png'), 1620, 1080),
    ('spr_zz_machine',      os.path.join(IMG, '425.png'), 1350, 852),
    ('spr_zz_title',        os.path.join(IMG, '670.png'), 252, 78),
    ('spr_zz_treasure_cap', os.path.join(IMG, '371.png'), 168, 43),
    # ── 格底（6 色）──
    ('spr_zz_cell_pink',    os.path.join(IMG, '23.png'),  111, 111),
    ('spr_zz_cell_green',   os.path.join(IMG, '335.png'), 111, 111),
    ('spr_zz_cell_blue',    os.path.join(IMG, '337.png'), 111, 111),
    ('spr_zz_cell_orange',  os.path.join(IMG, '339.png'), 111, 111),
    ('spr_zz_cell_purple',  os.path.join(IMG, '341.png'), 111, 111),
    ('spr_zz_cell_red',     os.path.join(IMG, '343.png'), 111, 111),
    ('spr_zz_frame_sel',    os.path.join(IMG, '97.png'),  123, 123),
    # ── 图标 ──
    ('spr_zz_star',         os.path.join(IMG, '411.png'), 60, 60),
    ('spr_zz_coin',         os.path.join(IMG, '559.png'), 36, 36),
    ('spr_zz_arrow',        os.path.join(IMG, '373.png'), 39, 42),
    # ── 按钮 ──
    ('spr_zz_btn_exshop',   os.path.join(IMG, '384.png'), 129, 48),
    ('spr_zz_btn_exchange', os.path.join(IMG, '100.png'), 108, 39),
    ('spr_zz_btn_close',    os.path.join(IMG, '61.png'),  82, 82),
    ('spr_zz_btn_again1',   os.path.join(IMG, '231.png'), 219, 75),
    ('spr_zz_btn_again10',  os.path.join(IMG, '238.png'), 219, 75),
    ('spr_zz_btn_again50',  os.path.join(PRE, 'btn_again50.png'), 219, 75),
    ('spr_zz_price_20000',   os.path.join(PRE, 'price_20000.png'),   285, 92),
    ('spr_zz_price_100000',  os.path.join(PRE, 'price_100000.png'),  285, 92),
    ('spr_zz_price_1000000', os.path.join(PRE, 'price_1000000.png'), 285, 92),
    # ── 页签 ──
    ('spr_zz_tab_lucky_on', os.path.join(IMG, '429.png'), 195, 57),
    ('spr_zz_side_lucky_on',  os.path.join(IMG, '780.png'), 174, 84),
    ('spr_zz_side_lucky_off', os.path.join(IMG, '778.png'), 174, 84),
    ('spr_zz_side_gift_on',   os.path.join(IMG, '790.png'), 174, 84),
    ('spr_zz_side_gift_off',  os.path.join(IMG, '788.png'), 174, 84),
    # ── 结果弹窗 ──
    ('spr_zz_panel',        os.path.join(IMG, '145.png'), 990, 750),
    ('spr_zz_congrats',     os.path.join(IMG, '215.png'), 432, 117),
    # ── 其它 ──
    ('spr_zz_enter',        ENTER, 84, 70),
]


def compose_enter(dst, w, h):
    """56×47 的源图写着「美食活动」→ 只取礼物图形，文字重排成「金马盛典」。"""
    from PIL import ImageDraw, ImageFont
    src = Image.open(ENTER).convert('RGBA').crop((0, 0, 56, 26))
    canvas = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    gw = w
    gh = max(1, int(round(26 * w / 56)))
    canvas.alpha_composite(src.resize((gw, gh), Image.LANCZOS), (0, 0))

    d = ImageDraw.Draw(canvas)
    f = ImageFont.truetype(r'C:/Windows/Fonts/msyhbd.ttc', 20)
    label = '金马盛典'
    tw = d.textlength(label, font=f)
    tx = (w - tw) / 2
    ty = gh - 3
    for ox, oy in ((-2, 0), (2, 0), (0, -2), (0, 2), (-2, -2), (2, -2), (-2, 2), (2, 2)):
        d.text((tx + ox, ty + oy), label, font=f, fill=(64, 28, 8, 255))
    d.text((tx, ty), label, font=f, fill=(255, 255, 255, 255))
    canvas.save(dst)


def main():
    os.makedirs(TMP, exist_ok=True)
    ok = 0
    for name, src, w, h in JOBS:
        if not os.path.exists(src):
            print('!! 源图缺失: %s (%s)' % (src, name))
            continue
        dst = os.path.join(TMP, name + '.png')
        if name == 'spr_zz_enter':
            compose_enter(dst, w, h)
        else:
            im = Image.open(src).convert('RGBA')
            if im.size != (w, h):
                im = im.resize((w, h), Image.LANCZOS)
            im.save(dst)
        build(name, [dst], w, h, 0, 0, 'cards', 'mod')
        ok += 1
    print('生成 %d / %d 个精灵' % (ok, len(JOBS)))


if __name__ == '__main__':
    main()
