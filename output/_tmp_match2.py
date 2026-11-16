import os, glob, json, re
import numpy as np
from PIL import Image

def load(path):
    s = open(path, encoding="utf-8-sig").read().replace("\x00","")
    s = re.sub(r",(\s*[}\]])", r"\1", s)
    return json.loads(s)

def compose(lv, W=1920, H=1080):
    spr = lv["map_sprite"]
    png = sorted(glob.glob(os.path.join("sprites", spr, "*.png")))[0]
    im = Image.open(png).convert("RGBA")
    bd = lv.get("bg_draw")
    canvas = Image.new("RGBA", (W,H), (0,0,0,255))
    if bd:
        w = max(1,int(round(im.width*bd["sx"]))); h = max(1,int(round(im.height*bd["sy"])))
        im2 = im.resize((w,h), Image.LANCZOS)
        canvas.paste(im2, (int(round(bd["x"])), int(round(bd["y"]))), im2)
    else:
        canvas.paste(im, (0,0))
    return canvas

shot = Image.open(r"D:\DSH\home\attachments\v1\objects\04\0487bdbddd653aae59337ed98e3a3ec3d40db55b9c85d522f3642a848933ccd3").convert("L")
T = np.asarray(shot, dtype=np.float64)
th, tw = T.shape
Tz = (T - T.mean())

levels = ["cross/shuihuo_0.json","cross/shuihuo_4.json","cross/zhuore_0.json","cross/wudu_0.json",
          "cross/nightmare_sky-0.json","cross/castle-0.json"]

for lv_path in levels:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    c = compose(lv).convert("L")
    best = (-2, None)
    for k in np.arange(0.3, 1.21, 0.1):
        w = int(round(1920*k)); h = int(round(1080*k))
        if w < tw or h < th: continue
        img = np.asarray(c.resize((w,h), Image.BILINEAR), dtype=np.float64)
        imgz = img - img.mean()
        F = np.fft.rfft2(imgz)
        Tp = np.fft.rfft2(Tz[::-1, ::-1], s=imgz.shape)
        corr = np.fft.irfft2(F*Tp, s=imgz.shape)
        corr = np.fft.fftshift(corr)
        # integral images for local sums and sums of squares
        ii1 = np.cumsum(np.cumsum(imgz,0),1); ii1 = np.vstack([np.zeros((1,imgz.shape[1])), ii1]); ii1=np.hstack([np.zeros((ii1.shape[0],1)), ii1])
        ii2 = np.cumsum(np.cumsum(imgz**2,0),1); ii2 = np.vstack([np.zeros((1,ii2.shape[1])), ii2]); ii2=np.hstack([np.zeros((ii2.shape[0],1)), ii2])
        def bs(ii,y,x):
            return ii[y+th, x+tw] - ii[y, x+tw] - ii[y+th, x] + ii[y, x]
        H_, W_ = imgz.shape
        # valid top-left positions
        ys = np.arange(0, H_-th+1); xs = np.arange(0, W_-tw+1)
        YY, XX = np.meshgrid(ys, xs, indexing="ij")
        S1 = bs(ii1, YY, XX); S2 = bs(ii2, YY, XX)
        var = S2 - S1**2/(th*tw)
        var = np.maximum(var, 1e-6)
        # corr coordinate: fftshift gives index (y + th -1, x + tw -1)? use direct formula
        cy = YY + th - 1; cx = XX + tw - 1
        cy = np.clip(cy, 0, corr.shape[0]-1); cx = np.clip(cx, 0, corr.shape[1]-1)
        cc = corr[cy, cx]
        ncc = cc / np.sqrt(var * (Tz**2).sum())
        i = int(np.argmax(ncc))
        val = float(ncc.ravel()[i])
        if val > best[0]:
            best = (val, (k, int(XX.ravel()[i]), int(YY.ravel()[i])))
    k, xx, yy = best[1]
    print(f"{lv_path:28s} NCC={best[0]:+.4f} scale={k:.2f} scene={xx/k:.0f},{yy/k:.0f} size={tw/k:.0f}x{th/k:.0f}")
