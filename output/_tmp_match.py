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
tmpl = np.asarray(shot, dtype=np.float32)
tmpl -= tmpl.mean()
th, tw = tmpl.shape

levels = ["cross/shuihuo_0.json","cross/shuihuo_4.json","cross/zhuore_0.json","cross/wudu_0.json",
          "cross/nightmare_sky-0.json","cross/castle-0.json"]

for lv_path in levels:
    lv = load(os.path.join("datafiles/level_data", lv_path))
    c = compose(lv).convert("L")
    best = (-2, None)
    for k in np.arange(0.20, 1.01, 0.05):
        w = int(round(1920*k)); h = int(round(1080*k))
        if w < tw or h < th: continue
        img = np.asarray(c.resize((w,h), Image.BILINEAR), dtype=np.float32)
        img -= img.mean()
        # FFT NCC (unnormalized zero-mean correlation / std of patch region approx)
        F = np.fft.rfft2(img)
        T = np.fft.rfft2(tmpl, s=img.shape)
        corr = np.fft.irfft2(F*np.conj(T), s=img.shape)
        # local sum of squares via integral image
        ii = np.cumsum(np.cumsum(img**2, axis=0), axis=1)
        def boxsum(y, x, hh, ww):
            A = ii[y+hh-1, x+ww-1]
            B = ii[y-1, x+ww-1] if y>0 else 0
            C = ii[y+hh-1, x-1] if x>0 else 0
            D = ii[y-1, x-1] if (y>0 and x>0) else 0
            return A-B-C+D
        ys, xs = np.mgrid[0:img.shape[0]-th+1, 0:img.shape[1]-tw+1]
        # subsample for speed
        step = 2
        ys = ys[::step, ::step]; xs = xs[::step, ::step]
        ss = np.array([[boxsum(y,x,th,tw) for x in row] for row in xs]) if False else None
        # vectorized boxsum using cumsum slices
        SS = ii[ys+th-1, xs+tw-1]
        SS = SS - ii[np.maximum(ys-1,0), xs+tw-1]*(ys>0) - ii[ys+th-1, np.maximum(xs-1,0)]*(xs>0) + ii[np.maximum(ys-1,0), np.maximum(xs-1,0)]*((ys>0)&(xs>0))
        cc = corr[ys, xs]
        ncc = cc / np.sqrt(np.maximum(SS, 1e-6))
        i = int(np.argmax(ncc))
        val = float(ncc.ravel()[i])
        if val > best[0]:
            yy = int(ys.ravel()[i]); xx = int(xs.ravel()[i])
            best = (val, (k, xx, yy))
    k, xx, yy = best[1]
    print(f"{lv_path:28s} best NCC={best[0]:.4f}  scale={k:.2f}  scene_pos=({xx/k:.0f},{yy/k:.0f})  scene_size=({tw/k:.0f}x{th/k:.0f})")
