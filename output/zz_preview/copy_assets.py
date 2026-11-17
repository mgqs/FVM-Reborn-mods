# -*- coding: utf-8 -*-
"""把「金马盛典」预览要用的 SWF 拆包位图复制到 assets/ 并改成语义名。

源目录: C:/Users/18203/Desktop/转转/images
只做复制，不改源图（幂等，可重复跑）。
"""
import os
import shutil
import sys

SRC = r"C:/Users/18203/Desktop/转转/images"
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "assets")

MAP = {
    # 场景 / 机台
    "667.png": "bg_stage.png",
    "425.png": "machine.png",
    "673.png": "podium_purple.png",
    "674.png": "podium_blue.png",
    "447.png": "machine_side.png",
    # 标题 / 条幅
    "670.png": "title.png",
    "671.png": "banner.png",
    "371.png": "txt_treasure.png",
    "443.png": "bar_consume.png",
    "446.png": "bar_bg.png",
    "506.png": "txt_gift.png",
    # 面板
    "59.png": "panel_white.png",
    "145.png": "panel_ribbon.png",
    "144.png": "panel_inner.png",
    "449.png": "cell_dark.png",
    # 格子底（星芒）
    "23.png": "cell_pink.png",
    "335.png": "cell_green.png",
    "337.png": "cell_blue.png",
    "339.png": "cell_orange.png",
    "341.png": "cell_purple.png",
    "343.png": "cell_red.png",
    "222.png": "cell_orange2.png",
    "530.png": "cell_tall_yellow.png",
    "531.png": "cell_tall_purple.png",
    "532.png": "cell_tall_blue.png",
    "533.png": "cell_tall_green.png",
    # 页签 / 按钮
    "429.png": "tab_lucky_on.png",
    "432.png": "tab_deluxe_on.png",
    "434.png": "tab_deluxe_off.png",
    "427.png": "tab_lucky_off.png",
    "778.png": "side_lucky_off.png",
    "780.png": "side_lucky_on.png",
    "788.png": "side_gift_off.png",
    "790.png": "side_gift_on.png",
    "384.png": "btn_exshop.png",
    "100.png": "btn_exchange.png",
    "373.png": "arrow_right.png",
    "299.png": "btn_spin1.png",
    "301.png": "btn_spin1b.png",
    "118.png": "btn_deluxe10.png",
    "111.png": "btn_deluxe1.png",
    "346.png": "price_200.png",
    "354.png": "price_1440.png",
    "278.png": "btn_minus.png",
    "282.png": "btn_plus.png",
    "292.png": "btn_max.png",
    "261.png": "btn_ok.png",
    "61.png": "btn_close.png",
    "231.png": "btn_again1.png",
    "238.png": "btn_again10.png",
    "362.png": "tag_8zhe.png",
    # 图标 / 文字
    "396.png": "item_clover3.png",
    "405.png": "item_clover4.png",
    "411.png": "icon_luckystar.png",
    "90.png": "icon_star.png",
    "215.png": "txt_congrats.png",
    "217.png": "txt_congrats2.png",
    "97.png": "frame_sel.png",
    "365.png": "frame_dark.png",
    "108.png": "icon_info.png",
}


def main():
    if not os.path.isdir(SRC):
        print("源目录不存在: %s" % SRC)
        return 1
    os.makedirs(OUT, exist_ok=True)
    # 数字 1..9,0 来自 SWF 的青色描边数字位图
    for n, src in zip("1234567890", [307, 309, 311, 313, 315, 317, 319, 321, 323, 325]):
        MAP["%d.png" % src] = "num_%s.png" % n
    missing, done = [], 0
    for src, dst in MAP.items():
        sp = os.path.join(SRC, src)
        if not os.path.exists(sp):
            missing.append(src)
            continue
        shutil.copy2(sp, os.path.join(OUT, dst))
        done += 1
    print("复制 %d 张 -> %s" % (done, OUT))
    if missing:
        print("缺失: %s" % ", ".join(missing))
    return 0


if __name__ == "__main__":
    sys.exit(main())
