#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
往 spr_craft_material 图集追加「金马盛典」新增材料图标（8 帧）。

来源：C:/Users/18203/Desktop/转转  (SWF 拆包, 44x44)
  xiangliao/0x123400b0  → icon 15  13★ 香料
  xiangliao/0x12340110  → icon 16  14★ 香料
  xiangliao/0x12340130  → icon 17  15★ 香料
  xiangliao/0x12340150  → icon 18  16★ 香料
  siyecao/0x123200a0    → icon 19  5 级四叶草
  siyecao/0x123200d0    → icon 20  6 级四叶草
  siyecao/0x123200b0    → icon 21  S 级四叶草
  siyecao/0x12320110    → icon 22  SS 级四叶草
  images/411.png        → icon 23  幸运星（金马盛典兑换货币）

图集帧尺寸 88×88（原图 44×44，2x 放大）。GMS 每帧要写两份：
  sprites/<名>/<帧GUID>.png                 顶层合成图（运行时/IDE 预览读它）
  sprites/<名>/layers/<帧GUID>/<图层GUID>.png  图层源图（单图层，必须与上面一致）
幂等：帧数已达 23 就直接退出。
"""
import io, json, os, re, uuid, shutil, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
from PIL import Image

SPR = "spr_craft_material"
YY = "sprites/%s/%s.yy" % (SPR, SPR)
SRC = "C:/Users/18203/Desktop/转转"

ITEMS = [
    ("xiangliao/0x123400b0.png", 15),
    ("xiangliao/0x12340110.png", 16),
    ("xiangliao/0x12340130.png", 17),
    ("xiangliao/0x12340150.png", 18),
    ("siyecao/0x123200a0.png", 19),
    ("siyecao/0x123200d0.png", 20),
    ("siyecao/0x123200b0.png", 21),
    ("siyecao/0x12320110.png", 22),
    ("images/411.png", 23),   # 幸运星（转转兑换货币）
]

TARGET = 24  # 15 原有 + 8 新材料 + 幸运星


def load_yy(path):
    txt = io.open(path, encoding="utf-8").read()
    clean = re.sub(r",(\s*[}\]])", r"\1", txt)
    return json.loads(clean)


def main():
    d = load_yy(YY)
    n_now = len(d["frames"])
    if n_now >= TARGET:
        print("already %d frames, skip" % n_now)
        return

    layer_guid = d["layers"][0]["name"]
    seq = d["sequence"]
    kfs = seq["tracks"][0]["keyframes"]["Keyframes"]
    W, H = d["width"], d["height"]

    for src_rel, icon in ITEMS:
        if icon < n_now:
            continue
        src = os.path.join(SRC, src_rel)
        im = Image.open(src).convert("RGBA")
        if im.size != (W, H):
            im = im.resize((W, H), Image.LANCZOS)
        guid = str(uuid.uuid4())
        top = "sprites/%s/%s.png" % (SPR, guid)
        lay_dir = "sprites/%s/layers/%s" % (SPR, guid)
        os.makedirs(lay_dir, exist_ok=True)
        im.save(top)
        im.save(os.path.join(lay_dir, "%s.png" % layer_guid))

        d["frames"].append({
            "$GMSpriteFrame": "v1",
            "%Name": guid,
            "name": guid,
            "resourceType": "GMSpriteFrame",
            "resourceVersion": "2.0",
        })
        kfs.append({
            "$Keyframe<SpriteFrameKeyframe>": "",
            "Channels": {"0": {
                "$SpriteFrameKeyframe": "",
                "Id": {"name": guid, "path": "%s.yy" % YY[:-3]},
                "resourceType": "SpriteFrameKeyframe",
                "resourceVersion": "2.0",
            }},
            "Disabled": False,
            "id": str(uuid.uuid4()),
            "IsCreationKey": False,
            "Key": float(icon),
            "Length": 1.0,
            "resourceType": "Keyframe<SpriteFrameKeyframe>",
            "resourceVersion": "2.0",
            "Stretch": False,
        })
        print("icon %2d  <-  %s" % (icon, src_rel))

    seq["length"] = float(len(d["frames"]))
    out = json.dumps(d, ensure_ascii=False, indent=2)
    io.open(YY, "w", encoding="utf-8", newline="\n").write(out)
    print("frames now", len(d["frames"]))


if __name__ == "__main__":
    main()
