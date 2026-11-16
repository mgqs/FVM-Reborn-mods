# -*- coding: utf-8 -*-
"""变异绿巨人：把"移动/冲刺"的翻滚动画换成跳跃动画。

现状：spr_kf_wd_hulk_move_slow（DISAPPEAR 走位）与 spr_kf_wd_hulk_move_fast（技能1/3 冲撞）
都是从 变异绿巨人.swf 的「变滚球/滚球」段（sprite 190 帧 94~108）重采样来的，
所以巨人一移动就变成一颗球在滚——用户反馈"翻滚不自然，应该是跳跃"。

做法：同帧数、同画布、同原点的原地替换，只换 PNG，不动 .yy 与对象代码：
  move_fast 24 帧 = 健康 SWF 110~121（起跳预备→腾空→落地扬尘）+ 受伤 SWF 320~331
  move_slow 30 帧 = 健康 SWF 109~123 + 受伤 SWF 319~333
受伤段 = 健康段 + 210（SWF FrameLabel 实测偏移）。

用法：
  python tools/hulk_move_to_jump.py --check
  python tools/hulk_move_to_jump.py
"""
import os
import shutil
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
from inf_zhanshen_repair import SPRITES, sprite_meta  # noqa: E402

SRC = (r"C:\Users\18203\Desktop\跨服\巫毒研究所\BOSS\sprites"
       r"\DefineSprite_190_com.aurora.ui.maogoutd.resource.Intruder"
       r".kfcarbon.newBoss.hulk.HulkBossMoveIntruderMovie")
HURT_OFFSET = 210
BACKUP = os.path.join(ROOT, "output", "_tmp")

# 精灵名 -> (每半段帧数, 健康段起始 SWF 帧号)
# 注意：swf_frame_labels 给的帧号是 0 基，ffdec 导出的 PNG 文件名是 1 基，
# 所以「跳跃预备(0 基 109)」对应 PNG 110。受伤段 = 健康段 + 210（同一 1 基口径）。
PLAN = {
    "spr_kf_wd_hulk_move_fast": (12, 110),
    "spr_kf_wd_hulk_move_slow": (15, 110),
}


def main():
    check = "--check" in sys.argv
    if not os.path.isdir(SRC):
        print("!! 找不到 SWF 导出目录: %s" % SRC)
        return 1
    for name, (half, base) in PLAN.items():
        W, H, layer, frames = sprite_meta(name)
        assert len(frames) == half * 2, "%s 帧数 %d != %d" % (name, len(frames), half * 2)
        dsts = []
        for i in range(half * 2):
            src_frame = base + (i if i < half else i - half + HURT_OFFSET)
            dsts.append(src_frame)
        if check:
            print("%-30s %dx%d %d 帧 <- SWF %d..%d / %d..%d" % (
                name, W, H, len(frames), dsts[0], dsts[half - 1],
                dsts[half], dsts[-1]))
            continue
        bak = os.path.join(BACKUP, "bak_" + name)
        if not os.path.exists(bak):
            shutil.copytree(os.path.join(SPRITES, name), bak)
        d = os.path.join(SPRITES, name)
        for i, src_frame in enumerate(dsts):
            sp = os.path.join(SRC, "%d.png" % src_frame)
            im = Image.open(sp)
            assert im.size == (W, H), "%s 尺寸 %s != %s" % (sp, im.size, (W, H))
            f = frames[i]
            fdir = os.path.join(d, "layers", f)
            os.makedirs(fdir, exist_ok=True)
            shutil.copyfile(sp, os.path.join(fdir, layer + ".png"))
            shutil.copyfile(sp, os.path.join(d, f + ".png"))
        print("%-30s 已换成跳跃动画（%d 帧）" % (name, len(frames)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
